class AddZakljucanoBrisanjeAndZakljucanoUredivanjeToZaglavljes < ActiveRecord::Migration
  def change
    add_column :zaglavljes, :zakljucano_brisanje, :boolean
    add_column :zaglavljes, :zakljucano_uredivanje, :boolean
  end
end
