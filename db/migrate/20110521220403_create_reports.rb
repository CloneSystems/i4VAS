class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.string :task_id
      t.string :task_name
      t.string :status
      t.string :started_at
      t.string :ended_at
      t.string :result_count

      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
