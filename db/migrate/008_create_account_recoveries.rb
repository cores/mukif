
class CreateAccountRecoveries < ActiveRecord::Migration

  def self.up
    create_table :account_recoveries do |t|
      t.column :user_id, :integer, :null => false
      t.column :code, :string, :null => false
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :account_recoveries
  end
end
