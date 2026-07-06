class LogsController < ApplicationController
  before_action :set_project

  def show
    @destination = params[:destination].presence
    @active_run = @project.command_runs.where(command_type: "logs").order(created_at: :desc).first
  end

  def create
    if @project.command_runs.running.where(command_type: "logs").exists?
      redirect_to project_logs_path(@project, destination: params[:destination]), alert: "Logs are already streaming."
      return
    end

    command_run = @project.command_runs.create!(
      command_type: "logs",
      destination: params[:destination].presence,
      status: "pending"
    )
    LogStreamJob.perform_later(command_run.id)
    redirect_to project_logs_path(@project, destination: params[:destination])
  end

  def destroy
    run = @project.command_runs.running.find_by(command_type: "logs")
    if run&.pid.present?
      Process.kill("INT", run.pid) rescue nil
      run.mark_cancelled!
    end
    redirect_to project_logs_path(@project, destination: params[:destination]), notice: "Log stream stopped."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
