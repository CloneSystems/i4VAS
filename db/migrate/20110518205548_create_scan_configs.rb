class CreateScanConfigs < ActiveRecord::Migration
  def self.up
    create_table :scan_configs do |t|
      t.string      :name
      t.text        :comment
      t.boolean     :families_grow
      t.boolean     :rules_grow
      t.boolean     :in_use
      t.timestamps
    end
  end

  def self.down
    drop_table :scan_configs
  end
end
