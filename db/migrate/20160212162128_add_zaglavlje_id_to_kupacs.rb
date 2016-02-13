class AddZaglavljeIdToKupacs < ActiveRecord::Migration
  def change
    add_column :kupacs, :zaglavlje_id, :integer
  end
end
