require "open3"

module Kamal
  class CommandRunner
    class RunnerError < StandardError; end

    def self.kamal_available?(project)
      run(project:, args: [ "version" ], timeout: 10).success
    rescue RunnerError
      false
    end

    def self.run(project:, args:, destination: nil, timeout: nil, on_output: nil)
      new(project:, destination:, on_output:).run(args, timeout:)
    end

    def initialize(project:, destination: nil, on_output: nil)
      @project = project
      @destination = destination.presence
      @on_output = on_output
    end

    def run(args, timeout: nil)
      command = build_command(args)
      output = +""
      exit_status = nil

      Dir.chdir(@project.root_path) do
        Open3.popen2e(*command) do |_stdin, stdout_stderr, wait_thr|
          reader = Thread.new do
            stdout_stderr.each do |line|
              output << line
              @on_output&.call(line)
            end
          end

          if timeout
            unless wait_thr.join(timeout)
              Process.kill("TERM", wait_thr.pid)
              raise RunnerError, "Command timed out after #{timeout}s"
            end
          else
            wait_thr.join
          end

          reader.join
          exit_status = wait_thr.value
        end
      end

      Result.new(output:, success: exit_status.success?, exit_code: exit_status.exitstatus)
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

    Result = Data.define(:output, :success, :exit_code)
  end
end
