class CreateZaglavljes < ActiveRecord::Migration
  def change
    create_table :zaglavljes do |t|
      t.date :datum_od
      t.date :datum_do
      t.integer :oib
      t.string :naziv
      t.string :mjesto
      t.string :ulica
      t.string :broj
      t.string :email
      t.string :sastavio_ime
      t.string :sastavio_prezime
      t.string :sastavio_tel
      t.string :sastavio_fax
      t.string :sastavio_email
      t.date :na_dan
      t.date :nisu_naplaceni_do

      t.timestamps null: false
    end
  end
end
