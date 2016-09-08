class CreateKupacRacuns < ActiveRecord::Migration
  def change
    create_table :kupac_racuns do |t|
      t.integer :kupac_id
      t.integer :racun_id

      t.timestamps null: false
    end
  end
end
