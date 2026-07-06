class ConsoleSessionJob < ApplicationJob
  queue_as :default

  def perform(command_run_id)
    command_run = CommandRun.find(command_run_id)
    return if command_run.finished?

    command_run.mark_running!
    ConsoleChannel.broadcast_to(command_run, { text: "\nConnecting to remote Rails console...\n\n" })

    session = Kamal::ConsoleSession.start(command_run)
    session.wait

    command_run.reload
    command_run.mark_finished!(exit_code: 0) unless command_run.status == "cancelled"
  ensure
    Kamal::ConsoleSession.stop(command_run.id) if command_run
  end
end
