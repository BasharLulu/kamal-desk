class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :root_path
      t.string :config_path
      t.json :destinations
      t.datetime :last_synced_at

      t.timestamps
    end
    add_index :projects, :root_path, unique: true
  end
end
