class DeploymentRun < ApplicationRecord
  STATUSES = %w[pending running succeeded failed cancelled].freeze

  belongs_to :project

  validates :command, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }

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
    update!(status:, exit_code:, finished_at: Time.current)
  end

  def mark_cancelled!
    update!(status: "cancelled", finished_at: Time.current)
  end
end
