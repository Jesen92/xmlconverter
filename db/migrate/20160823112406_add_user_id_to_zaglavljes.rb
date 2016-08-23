class AddUserIdToZaglavljes < ActiveRecord::Migration
  def change
    add_column :zaglavljes, :user_id, :integer
  end
end
