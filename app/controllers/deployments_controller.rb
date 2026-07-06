class DeploymentsController < ApplicationController
  before_action :set_project

  def create
    command = deployment_params[:command]
    destination = deployment_params[:destination].presence
    version = deployment_params[:version].presence

    lock = Kamal::LockInspector.new(project: @project, destination: destination)
    if lock.locked? && command != "lock"
      redirect_to project_path(@project, destination: destination), alert: "Deploy lock is active. Release it before deploying.
#{lock.status}"
      return
    end

    command_string = if command == "rollback" && version.present?
      "rollback #{version}"
    else
      command
    end

    if @project.deployment_runs.exists?(status: "running")
      redirect_to project_path(@project, destination: destination), alert: "A deployment is already running for this project."
      return
    end

    deployment_run = @project.deployment_runs.create!(
      command: command_string,
      destination: destination,
      version: version,
      status: "pending"
    )

    DeploymentJob.perform_later(deployment_run.id)
    redirect_to deployment_run_path(deployment_run)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def deployment_params
    params.require(:deployment).permit(:command, :destination, :version)
  end
end
