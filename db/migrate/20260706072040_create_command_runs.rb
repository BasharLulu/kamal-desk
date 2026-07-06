class CreateCommandRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :command_runs do |t|
      t.references :project, null: false, foreign_key: true
      t.string :command_type
      t.string :status
      t.string :destination
      t.text :output
      t.integer :pid
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :exit_code

      t.timestamps
    end
  end
end
