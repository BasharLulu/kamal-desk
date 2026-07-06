require "open3"
require "shellwords"

module Kamal
  class CommandRunner
    class RunnerError < StandardError; end

    def self.kamal_available?(project)
      run(project:, args: [ "version" ], timeout: 10).success
    rescue RunnerError
      false
    end

    def self.run(project:, args:, destination: nil, timeout: nil, on_output: nil, on_start: nil, should_stop: nil)
      new(project:, destination:, on_output:, on_start:, should_stop:).run(args, timeout:)
    end

    def initialize(project:, destination: nil, on_output: nil, on_start: nil, should_stop: nil)
      @project = project
      @destination = destination.presence
      @on_output = on_output
      @on_start = on_start
      @should_stop = should_stop
    end

    def run(args, timeout: nil)
      command = build_command(args)
      output = +""
      exit_status = nil
      stopped = false

      Open3.popen2e(*command, chdir: @project.root_path) do |_stdin, stdout_stderr, wait_thr|
        @on_start&.call(wait_thr.pid)

        reader = Thread.new do
          stdout_stderr.each do |line|
            if @should_stop&.call
              stopped = true
              Process.kill("INT", wait_thr.pid) rescue nil
              break
            end

            output << line
            @on_output&.call(line)
          end
        end

        if timeout
          unless wait_thr.join(timeout)
            Process.kill("TERM", wait_thr.pid) rescue nil
            raise RunnerError, "Command timed out after #{timeout}s"
          end
        else
          wait_thr.join
        end

        reader.join
        exit_status = wait_thr.value
      end

      Result.new(
        output: output,
        success: stopped ? false : exit_status.success?,
        exit_code: stopped ? 130 : exit_status.exitstatus,
        stopped: stopped
      )
    end

    private

    def build_command(args)
      sanitized_args = Array(args).map(&:to_s)
      command = kamal_executable + sanitized_args
      command += [ "-d", @destination ] if @destination
      command += [ "-c", @project.config_relative_path ] unless @project.config_relative_path == "config/deploy.yml"
      command
    end

    def kamal_executable
      if File.file?(File.join(@project.root_path, "Gemfile"))
        [ "bundle", "exec", "kamal" ]
      else
        [ "kamal" ]
      end
    end

    Result = Data.define(:output, :success, :exit_code, :stopped)
  end
end
