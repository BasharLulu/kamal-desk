class CreateDeploymentRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :deployment_runs do |t|
      t.references :project, null: false, foreign_key: true
      t.string :command, null: false
      t.string :destination
      t.string :status, null: false, default: "pending"
      t.string :version
      t.text :output
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :exit_code

      t.timestamps
    end
  end
end
