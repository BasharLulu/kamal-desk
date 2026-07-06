class AuditsController < ApplicationController
  before_action :set_project

  def show
    result = Kamal::CommandRunner.run(
      project: @project,
      destination: destination,
      args: [ "audit" ],
      timeout: 30
    )
    @audit_output = result.output
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def destination
    params[:destination].presence
  end
end
