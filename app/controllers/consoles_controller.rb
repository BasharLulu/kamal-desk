class ConsolesController < ApplicationController
  before_action :set_project

  def show
    @destination = params[:destination].presence
    @active_run = @project.command_runs.where(command_type: "console").order(created_at: :desc).first
  end

  def create
    if @project.command_runs.running.where(command_type: "console").exists?
      redirect_to project_console_path(@project, destination: params[:destination]), alert: "Console session already active."
      return
    end

    command_run = @project.command_runs.create!(
      command_type: "console",
      destination: params[:destination].presence,
      status: "pending"
    )
    ConsoleSessionJob.perform_later(command_run.id)
    redirect_to project_console_path(@project, destination: params[:destination])
  end

  def destroy
    run = @project.command_runs.running.find_by(command_type: "console")
    run&.mark_cancelled!
    Kamal::ConsoleSession.stop(run.id) if run
    redirect_to project_console_path(@project, destination: params[:destination]), notice: "Console closed."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
