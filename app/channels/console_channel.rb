class ConsoleChannel < ApplicationCable::Channel
  def subscribed
    command_run = CommandRun.find(params[:command_run_id])
    stream_for command_run
  end

  def receive(data)
    command_run = CommandRun.find(params[:command_run_id])
    session = Kamal::ConsoleSession.find(command_run.id)
    return unless session

    case data["action"]
    when "input"
      session.write(data["text"])
    when "resize"
      session.resize(data["rows"], data["cols"])
    end
  end

  def unsubscribed
    command_run = CommandRun.find_by(id: params[:command_run_id])
    return unless command_run&.running?

    command_run.mark_cancelled!
    Kamal::ConsoleSession.stop(command_run.id)
  end
end
