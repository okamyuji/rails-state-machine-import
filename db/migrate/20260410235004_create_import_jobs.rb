class CreateImportJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :import_jobs do |t|
      t.string :name, null: false
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.string :status, null: false, default: "idle"
      t.string :error_message

      t.timestamps
    end

    add_index :import_jobs, :status
  end
end
