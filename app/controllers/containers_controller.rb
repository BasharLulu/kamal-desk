class ContainersController < ApplicationController
  before_action :set_project

  def show
    inspector = Kamal::ContainerInspector.new(project: @project, destination: destination)
    @containers = inspector.containers
    @details = inspector.details
    @versions = inspector.versions_for_rollback
    @all_details = inspector.all_details
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def destination
    params[:destination].presence
  end
end
