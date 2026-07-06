module Kamal
  class ContainerInspector
    def initialize(project:, destination: nil)
      @project = project
      @destination = destination
    end

    def containers
      run("app", "containers")
    end

    def details
      run("app", "details")
    end

    def all_details
      run("details")
    end

    def versions_for_rollback
      result = run("app", "containers", "-q")
      parse_versions(result)
    end

    private

    def run(*args)
      CommandRunner.run(project: @project, destination: @destination, args:, timeout: 30).output
    end

    def parse_versions(output)
      output.scan(/([a-f0-9]{7,40})/).flatten.uniq
    end
  end
end
