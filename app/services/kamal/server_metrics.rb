module Kamal
  class ServerMetrics
    def initialize(project:, destination: nil)
      @project = project
      @destination = destination
    end

    def fetch
      CommandRunner.run(
        project: @project,
        destination: @destination,
        args: [
          "server", "exec",
          'docker stats --no-stream --format "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'
        ],
        timeout: 30
      ).output
    end
  end
end
