class AddUserIdToKupacs < ActiveRecord::Migration
  def change
    add_column :kupacs, :user_id, :integer
  end
end
