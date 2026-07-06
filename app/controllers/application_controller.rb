class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_sidebar_projects
  before_action :http_basic_authenticate, if: -> { ENV["KAMAL_DESK_PASSWORD"].present? }

  private

  def set_sidebar_projects
    @sidebar_projects = Project.order(:name)
  end

  def http_basic_authenticate
    authenticate_or_request_with_http_basic("Kamal Desk") do |username, password|
      username == ENV.fetch("KAMAL_DESK_USERNAME", "admin") && password == ENV["KAMAL_DESK_PASSWORD"]
    end
  end
end
