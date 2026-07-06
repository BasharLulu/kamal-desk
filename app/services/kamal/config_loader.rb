require "kamal"

module Kamal
  class ConfigLoader
    Summary = Data.define(:destination, :service, :image, :hosts, :proxy_host, :proxy_ssl, :accessories, :aliases, :error)

    def initialize(project:)
      @project = project
    end

    def summaries
      destinations = [ nil, *@project.destinations ]
      destinations.map { |destination| load_summary(destination) }
    end

    def load_summary(destination = nil)
      config_file = Pathname.new(@project.config_path)
      configuration = Kamal::Configuration.create_from(config_file:, destination:)
      raw = configuration.raw_config

      Summary.new(
        destination: destination || "default",
        service: configuration.service,
        image: raw.image.to_s,
        hosts: extract_hosts(configuration),
        proxy_host: configuration.proxy&.hosts&.join(", "),
        proxy_ssl: configuration.proxy&.ssl?,
        accessories: configuration.accessories.map(&:name),
        aliases: configuration.aliases.keys,
        error: nil
      )
    rescue StandardError => e
      Summary.new(
        destination: destination || "default",
        service: nil,
        image: nil,
        hosts: [],
        proxy_host: nil,
        proxy_ssl: nil,
        accessories: [],
        aliases: [],
        error: e.message
      )
    end

    private

    def extract_hosts(configuration)
      configuration.servers.roles.flat_map do |role|
        role.hosts.map { |host| { role: role.name, host: host } }
      end
    end
  end
end
