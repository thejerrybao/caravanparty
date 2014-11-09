class CreateCaravanUsers < ActiveRecord::Migration
  def change
    create_table :caravan_users do |t|
      t.integer :caravan_id
      t.integer :user_id
      t.boolean :is_host
      t.boolean :accepted_invitation
      t.timestamp :created_at

      t.timestamps
    end
  end
end
