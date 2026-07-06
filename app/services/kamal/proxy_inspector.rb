module Kamal
  class ProxyInspector
    Route = Data.define(:service, :host, :target, :state, :tls)

    def initialize(project:, destination: nil)
      @project = project
      @destination = destination
    end

    def routes
      result = CommandRunner.run(
        project: @project,
        destination: @destination,
        args: [ "server", "exec", "--primary", "docker exec kamal-proxy kamal-proxy list" ],
        timeout: 30
      )
      parse_list(result.output)
    end

    def details
      CommandRunner.run(
        project: @project,
        destination: @destination,
        args: [ "proxy", "details" ],
        timeout: 30
      ).output
    end

    private

    def parse_list(output)
      lines = output.lines.map(&:strip).reject(&:blank?)
      return [] if lines.empty?

      header_index = lines.find_index { |line| line.match?(/^Service\s+Host/) }
      return [] unless header_index

      lines[(header_index + 1)..].filter_map do |line|
        parts = line.split(/\s+/, 5)
        next if parts.size < 4

        Route.new(
          service: parts[0],
          host: parts[1],
          target: parts[2],
          state: parts[3],
          tls: parts[4]
        )
      end
    end
  end
end
