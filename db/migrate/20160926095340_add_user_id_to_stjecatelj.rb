class AddUserIdToStjecatelj < ActiveRecord::Migration
  def change
    add_column :stjecateljs, :user_id, :integer
  end
end
