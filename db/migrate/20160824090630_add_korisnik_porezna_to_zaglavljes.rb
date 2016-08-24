class AddKorisnikPoreznaToZaglavljes < ActiveRecord::Migration
  def change
    add_column :zaglavljes, :korisnik_porezna, :string
  end
end
