class CommandRun < ApplicationRecord
  STATUSES = %w[pending running succeeded failed cancelled].freeze
  TYPES = %w[logs console].freeze

  belongs_to :project

  validates :command_type, presence: true, inclusion: { in: TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }
  scope :running, -> { where(status: "running") }

  def running?
    status == "running"
  end

  def finished?
    %w[succeeded failed cancelled].include?(status)
  end

  def append_output!(text)
    update!(output: "#{output}#{text}")
  end

  def mark_running!
    update!(status: "running", started_at: Time.current)
  end

  def mark_finished!(exit_code:)
    status = exit_code.zero? ? "succeeded" : "failed"
    update!(status:, exit_code:, finished_at: Time.current, pid: nil)
  end

  def mark_cancelled!
    update!(status: "cancelled", finished_at: Time.current, pid: nil)
  end
end
