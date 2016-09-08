class AddZaglavljeIdToRacuns < ActiveRecord::Migration
  def change
    add_column :racuns, :zaglavlje_id, :integer
  end
end
