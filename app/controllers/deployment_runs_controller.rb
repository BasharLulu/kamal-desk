class DeploymentRunsController < ApplicationController
  def show
    @deployment_run = DeploymentRun.find(params[:id])
    @project = @deployment_run.project
  end
end
