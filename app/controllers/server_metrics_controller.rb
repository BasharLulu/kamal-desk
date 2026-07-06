class ServerMetricsController < ApplicationController
  before_action :set_project

  def show
    @metrics = metrics_service.fetch
  end

  def refresh
    metrics_service.bust_cache
    @metrics = metrics_service.fetch
    render partial: "server_metrics/metrics", locals: { metrics: @metrics }
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def destination
    params[:destination].presence
  end

  def metrics_service
    Kamal::ServerMetrics.new(project: @project, destination: destination)
  end
end
