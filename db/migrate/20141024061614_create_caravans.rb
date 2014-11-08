class CreateCaravans < ActiveRecord::Migration
  def change
    create_table :caravans, id: false do |t|
      t.primary_key :caravan_id
      t.integer :host_user_id
      t.float :dest_latitude
      t.float :dest_longitude
      t.boolean :is_active
      t.timestamp :created_at
      t.timestamp :ended_at

      t.timestamps
    end
  end
end
