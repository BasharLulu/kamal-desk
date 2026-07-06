module Kamal
  class ServerMetrics
    def initialize(project:, destination: nil)
      @project = project
      @destination = destination
    end

    def fetch
      Rails.cache.fetch(cache_key, expires_in: 15.seconds) do
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

    def bust_cache
      Rails.cache.delete(cache_key)
    end

    private

    def cache_key
      [ "kamal-desk", "server-metrics", @project.id, @destination ].join(":")
    end
  end
end
