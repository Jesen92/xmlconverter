class CreateKupacZaglavljes < ActiveRecord::Migration
  def change
    create_table :kupac_zaglavljes do |t|
      t.integer :zaglavlje_id
      t.integer :kupac_id

      t.timestamps null: false
    end
  end
end
