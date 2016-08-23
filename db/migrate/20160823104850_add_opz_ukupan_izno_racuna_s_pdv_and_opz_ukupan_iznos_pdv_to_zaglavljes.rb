class AddOpzUkupanIznoRacunaSPdvAndOpzUkupanIznosPdvToZaglavljes < ActiveRecord::Migration
  def change
    add_column :zaglavljes, :opz_ukupan_iznos_racuna_s_pdv, :decimal
    add_column :zaglavljes, :opz_ukupan_iznos_pdv, :decimal
  end
end
