class AddKorisnikPreuzeoXmlToZaglavljes < ActiveRecord::Migration
  def change
    add_column :zaglavljes, :korisnik_preuzeo_xml, :string
  end
end
