class DeploymentJob < ApplicationJob
  queue_as :default

  def perform(deployment_run_id)
    deployment_run = DeploymentRun.find(deployment_run_id)
    return if deployment_run.finished?

    deployment_run.mark_running!
    broadcast(deployment_run, "\n$ kamal #{deployment_run.command}\n\n")

    args = Shellwords.split(deployment_run.command)
    result = Kamal::CommandRunner.run(
      project: deployment_run.project,
      destination: deployment_run.destination,
      args: args,
      on_start: ->(pid) { deployment_run.update!(pid: pid) },
      on_output: ->(line) { broadcast(deployment_run, line) },
      should_stop: -> { deployment_run.reload.status == "cancelled" }
    )

    if deployment_run.reload.status == "cancelled"
      broadcast(deployment_run, "\n\n[cancelled]\n")
    else
      deployment_run.mark_finished!(exit_code: result.exit_code)
      broadcast(deployment_run, "\n\n[exit #{result.exit_code}]\n")
    end
  ensure
    deployment_run&.update!(pid: nil) if deployment_run&.reload&.finished?
  end

  private

  def broadcast(deployment_run, text)
    deployment_run.append_output!(text)
    CommandOutputChannel.broadcast_to(deployment_run, { text: })
  end
end
