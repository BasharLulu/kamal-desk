class ProxyController < ApplicationController
  before_action :set_project

  def show
    inspector = Kamal::ProxyInspector.new(project: @project, destination: destination)
    @routes = inspector.routes
    @details = inspector.details
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def destination
    params[:destination].presence
  end
end
