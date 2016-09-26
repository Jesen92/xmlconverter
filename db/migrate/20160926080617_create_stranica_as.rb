class CreateStranicaAs < ActiveRecord::Migration
  def change
    create_table :stranica_as do |t|
      t.integer :vrsta_izvjesca
      t.string :naziv
      t.string :mjesto
      t.string :ulica
      t.string :broj
      t.string :email
      t.string :oib
      t.string :oznaka_podnositelja
      t.integer :user_id
      t.boolean :zakljucano_brisanje
      t.boolean :zakljucano_uredivanje
      t.datetime :kreiran_xml
      t.datetime :poslan_na_poreznu
      t.integer :stranica_b_id

      t.timestamps null: false
    end
  end
end
