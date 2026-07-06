class LogStreamJob < ApplicationJob
  queue_as :default

  def perform(command_run_id)
    command_run = CommandRun.find(command_run_id)
    return if command_run.finished?

    command_run.mark_running!
    LogStreamChannel.broadcast_to(command_run, { text: "\n$ kamal app logs -f\n\n" })

    Kamal::LogStreamer.start(command_run)

    if command_run.reload.status == "cancelled"
      LogStreamChannel.broadcast_to(command_run, { text: "\n\n[stopped]\n" })
    else
      command_run.mark_finished!(exit_code: 0)
    end
  end
end
