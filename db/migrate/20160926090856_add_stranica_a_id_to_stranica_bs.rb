class AddStranicaAIdToStranicaBs < ActiveRecord::Migration
  def change
    add_column :stranica_bs, :stranica_a_id, :integer
  end
end
