class AddPidToDeploymentRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :deployment_runs, :pid, :integer
  end
end
