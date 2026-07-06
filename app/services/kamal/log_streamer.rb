module Kamal
  class LogStreamer
    def self.start(command_run)
      new(command_run).start
    end

    def initialize(command_run)
      @command_run = command_run
      @project = command_run.project
      @destination = command_run.destination.presence
    end

    def start
      args = %w[app logs -f]
      CommandRunner.run(
        project: @project,
        destination: @destination,
        args: args,
        on_start: ->(pid) { @command_run.update!(pid: pid) },
        on_output: ->(line) { broadcast(line) },
        should_stop: -> { @command_run.reload.status == "cancelled" }
      )
    end

    private

    def broadcast(text)
      @command_run.append_output!(text)
      LogStreamChannel.broadcast_to(@command_run, { text: })
    end
  end
end
