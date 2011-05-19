class CreateScanTargets < ActiveRecord::Migration
  def self.up
    create_table :scan_targets do |t|
      t.string      :name
      t.text        :comment
      t.text        :hosts
      t.text        :port_range
      t.boolean     :in_use
      t.timestamps
    end
  end

  def self.down
    drop_table :scan_targets
  end
end
