module Kamal
  class AuditReader
    def initialize(project:, destination: nil)
      @project = project
      @destination = destination
    end

    def fetch(limit_lines: 30)
      Rails.cache.fetch(cache_key, expires_in: 30.seconds) do
        output = CommandRunner.run(
          project: @project,
          destination: @destination,
          args: %w[audit],
          timeout: 30
        ).output
        Kamal::SecretFilter.redact(output.lines.last(limit_lines).join)
      end
    end

    private

    def cache_key
      [ "kamal-desk", "audit", @project.id, @destination ].join(":")
    end
  end
end
