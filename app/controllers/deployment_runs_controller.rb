class DeploymentRunsController < ApplicationController
  def show
    @deployment_run = DeploymentRun.find(params[:id])
    @project = @deployment_run.project
  end

  def cancel
    deployment_run = DeploymentRun.find(params[:id])

    if deployment_run.running? && deployment_run.pid.present?
      Process.kill("INT", deployment_run.pid) rescue nil
      deployment_run.mark_cancelled!
      redirect_to deployment_run, notice: "Deployment cancelled."
    else
      redirect_to deployment_run, alert: "No running deployment to cancel."
    end
  end
end
