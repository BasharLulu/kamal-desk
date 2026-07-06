module Kamal
  class DestinationDiscovery
    def self.call(root)
      Dir.glob(File.join(root, "config", "deploy.*.yml")).filter_map do |path|
        name = File.basename(path).delete_prefix("deploy.").delete_suffix(".yml")
        name unless name == "yml" || name.blank?
      end.sort
    end
  end
end
