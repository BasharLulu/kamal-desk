require "pty"

module Kamal
  class ConsoleSession
    REGISTRY = {}

    def self.start(command_run)
      session = new(command_run)
      session.start
      REGISTRY[command_run.id] = session
      session
    end

    def self.find(command_run_id)
      REGISTRY[command_run_id]
    end

    def self.stop(command_run_id)
      REGISTRY.delete(command_run_id)&.stop
    end

    def initialize(command_run)
      @command_run = command_run
      @project = command_run.project
      @destination = command_run.destination.presence
      @reader_thread = nil
    end

    def start
      command = build_command
      @master, slave = PTY.open
      @pid = Process.spawn(*command, in: slave, out: slave, err: slave, chdir: @project.root_path)
      slave.close
      @command_run.update!(pid: @pid)
      @reader_thread = Thread.new { read_loop }
    end

    def write(input)
      @master.write(input)
    rescue IOError, Errno::EIO
      nil
    end

    def resize(rows, cols)
      @master.winsize = [ rows, cols ]
    rescue StandardError
      nil
    end

    def wait
      @reader_thread&.join
    end

    def stop
      @reader_thread&.kill
      Process.kill("TERM", @pid) if @pid
      @master&.close
    rescue Errno::ESRCH, IOError
      nil
    end

    private

    def build_command
      base = if File.file?(File.join(@project.root_path, "Gemfile"))
        [ "bundle", "exec", "kamal" ]
      else
        [ "kamal" ]
      end
      args = base + %w[app exec -i --reuse bin/rails console]
      args += [ "-d", @destination ] if @destination
      args += [ "-c", @project.config_relative_path ] unless @project.config_relative_path == "config/deploy.yml"
      args
    end

    def read_loop
      loop do
        data = @master.readpartial(1024)
        @command_run.append_output!(data)
        ConsoleChannel.broadcast_to(@command_run, { text: data })
      end
    rescue EOFError, IOError, Errno::EIO
      ConsoleChannel.broadcast_to(@command_run, { closed: true })
    end
  end
end
