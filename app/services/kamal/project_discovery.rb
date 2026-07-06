module Kamal
  class ProjectDiscovery
    Entry = Data.define(:path, :name, :registered)

    def self.scan(roots: Project::ALLOWED_ROOTS, max_depth: 2)
      roots.flat_map { |root| scan_tree(root, max_depth) }.uniq(&:path)
    end

    def self.scan_tree(root, max_depth, depth = 0)
      return [] unless File.directory?(root)

      entries = []
      if Project.discover_config_path(root)
        entries << Entry.new(
          path: File.expand_path(root),
          name: File.basename(root),
          registered: Project.exists?(root_path: File.expand_path(root))
        )
      end

      return entries if depth >= max_depth

      Dir.children(root).sort.each do |child|
        next if child.start_with?(".")

        child_path = File.join(root, child)
        entries.concat(scan_tree(child_path, max_depth, depth + 1)) if File.directory?(child_path)
      end

      entries
    rescue Errno::EACCES, Errno::ENOENT
      []
    end
  end
end
