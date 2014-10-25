class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: false do |t|
      t.primary_key :user_id
      t.string :username
      t.string :password
      t.float :latitude
      t.float :longitude
      t.boolean :is_visible

      t.timestamps
    end
  end
end
