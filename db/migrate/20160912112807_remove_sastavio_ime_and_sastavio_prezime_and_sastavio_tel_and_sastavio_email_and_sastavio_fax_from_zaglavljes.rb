class RemoveSastavioImeAndSastavioPrezimeAndSastavioTelAndSastavioEmailAndSastavioFaxFromZaglavljes < ActiveRecord::Migration
  def change
    remove_column :zaglavljes, :sastavio_ime, :string
    remove_column :zaglavljes, :sastavio_prezime, :string
    remove_column :zaglavljes, :sastavio_tel, :string
    remove_column :zaglavljes, :sastavio_email, :string
    remove_column :zaglavljes, :sastavio_fax, :string
  end
end
