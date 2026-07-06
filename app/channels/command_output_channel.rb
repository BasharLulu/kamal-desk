class CommandOutputChannel < ApplicationCable::Channel
  def subscribed
    deployment_run = DeploymentRun.find(params[:deployment_run_id])
    stream_for deployment_run
  end
end
