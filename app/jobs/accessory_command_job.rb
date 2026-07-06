class AccessoryCommandJob < ApplicationJob
  queue_as :default

  def perform(command_run_id, args)
    command_run = CommandRun.find(command_run_id)
    return if command_run.finished?

    command_run.mark_running!
    result = Kamal::CommandRunner.run(
      project: command_run.project,
      destination: command_run.destination,
      args: args,
      timeout: args.include?("-f") ? nil : 60,
      on_output: ->(line) { command_run.append_output!(line) }
    )
    command_run.mark_finished!(exit_code: result.exit_code)
  end
end
