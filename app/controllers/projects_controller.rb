class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show destroy refresh]

  def index
    @projects = Project.order(:name)
    @project = Project.new
  end

  def show
    @destination = params[:destination].presence
    @config_summaries = Kamal::ConfigLoader.new(project: @project).summaries
    @deployment_runs = @project.deployment_runs.recent.limit(20)
    @kamal_available = @project.kamal_available?
  end

  def create
    @project = Project.register!(project_params[:root_path])
    redirect_to @project, notice: "Project registered."
  rescue ActiveRecord::RecordInvalid => e
    @projects = Project.order(:name)
    @project = Project.new(project_params)
    flash.now[:alert] = e.record.errors.full_messages.to_sentence.presence || e.message
    render :index, status: :unprocessable_entity
  end

  def destroy
    @project.destroy!
    redirect_to projects_path, notice: "Project removed."
  end

  def refresh
    @project.refresh!
    redirect_to @project, notice: "Project refreshed."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:root_path)
  end
end
