class CreateKupacs < ActiveRecord::Migration
  def change
    create_table :kupacs do |t|
      t.integer :r_b
      t.integer :oznaka_poreznog_broja
      t.string :porezni_broj
      t.string :naziv_kupca

      t.timestamps null: false
    end
  end
end
