class CreateRacuns < ActiveRecord::Migration
  def change
    create_table :racuns do |t|
      t.string :broj_izdanog_racuna
      t.date :datum_izdanog_racuna
      t.date :valuta_placanja_racuna
      t.integer :broj_dana_kasnjenja
      t.decimal :iznos_racuna
      t.decimal :iznos_pdv
      t.decimal :ukupan_iznos_racuna_pdv
      t.decimal :placeni_iznos_racuna
      t.decimal :neplaceni_dio_racuna

      t.timestamps null: false
    end
  end
end
