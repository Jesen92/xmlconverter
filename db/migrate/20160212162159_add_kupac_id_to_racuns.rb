class AddKupacIdToRacuns < ActiveRecord::Migration
  def change
    add_column :racuns, :kupac_id, :integer
  end
end
