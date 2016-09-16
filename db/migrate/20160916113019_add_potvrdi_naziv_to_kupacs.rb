class AddPotvrdiNazivToKupacs < ActiveRecord::Migration
  def change
    add_column :kupacs, :potvrdi_naziv, :boolean
  end
end
