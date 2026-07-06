class AccessoriesController < ApplicationController
  before_action :set_project

  def show
    @destination = params[:destination].presence
  end

  def create
    accessory = params[:accessory]
    action = params[:accessory_action]

    args = case action
    when "boot" then [ "accessory", "boot", accessory ]
    when "logs" then [ "accessory", "logs", accessory, "-f" ]
    else
      redirect_to project_accessories_path(@project, destination: destination), alert: "Unknown action."
      return
    end

    command_run = @project.command_runs.create!(
      command_type: "logs",
      destination: destination,
      status: "pending",
      output: "$ kamal #{args.join(' ')}\n\n"
    )
    AccessoryCommandJob.perform_later(command_run.id, args)
    redirect_to project_accessories_path(@project, destination: destination), notice: "Running kamal #{args.join(' ')}"
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def destination
    params[:destination].presence
  end
end
