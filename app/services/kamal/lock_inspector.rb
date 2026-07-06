module Kamal
  class LockInspector
    def initialize(project:, destination: nil)
      @project = project
      @destination = destination
    end

    def status
      Kamal::CommandRunner.run(
        project: @project,
        destination: @destination,
        args: %w[lock status],
        timeout: 15
      ).output.strip
    end

    def locked?
      status.match?(/locked/i)
    end
  end
end
