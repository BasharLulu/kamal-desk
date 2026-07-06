class DeploymentJob < ApplicationJob
  queue_as :default

  def perform(deployment_run_id)
    deployment_run = DeploymentRun.find(deployment_run_id)
    return if deployment_run.finished?

    deployment_run.mark_running!
    broadcast(deployment_run, "\n$ kamal #{deployment_run.command}\n\n")

    args = deployment_run.command.split
    result = Kamal::CommandRunner.run(
      project: deployment_run.project,
      destination: deployment_run.destination,
      args: args,
      on_output: ->(line) { broadcast(deployment_run, line) }
    )

    deployment_run.mark_finished!(exit_code: result.exit_code)
    broadcast(deployment_run, "\n\n[exit #{result.exit_code}]\n")
  end

  private

  def broadcast(deployment_run, text)
    deployment_run.append_output!(text)
    CommandOutputChannel.broadcast_to(deployment_run, { text: })
  end
end
