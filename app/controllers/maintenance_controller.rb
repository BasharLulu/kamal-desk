class MaintenanceController < ApplicationController
  before_action :set_project

  def create
    command = params[:mode] == "live" ? %w[app live] : %w[app maintenance]
    message = params[:message].presence

    args = command.dup
    args += [ "--message", message ] if message && params[:mode] != "live"

    result = Kamal::CommandRunner.run(
      project: @project,
      destination: destination,
      args: args,
      timeout: 30
    )

    flash_key = result.success ? :notice : :alert
    redirect_to project_path(@project, destination: destination), flash_key => result.output.presence || "Mode updated."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def destination
    params[:destination].presence
  end
end
