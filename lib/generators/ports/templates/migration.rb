class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :ports do |t|
      #t.column :user_id, :integer
      t.column :type, :string
      t.column :im_or_ex, :string
      t.column :data, :text
      t.column :created_at, :datetime
      t.column :rows_added, :integer
      t.column :rows_deleted, :integer
      t.column :rows_updated, :integer
    end

    add_index :ports, :type
  end

  def self.down
    drop_table :ports
  end
end
