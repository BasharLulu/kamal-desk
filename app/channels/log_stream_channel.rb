class LogStreamChannel < ApplicationCable::Channel
  def subscribed
    command_run = CommandRun.find(params[:command_run_id])
    stream_for command_run
  end
end
