class ServerMetricsController < ApplicationController
  before_action :set_project

  def show
    @metrics = Kamal::ServerMetrics.new(project: @project, destination: destination).fetch
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def destination
    params[:destination].presence
  end
end
