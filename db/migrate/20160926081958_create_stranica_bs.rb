class CreateStranicaBs < ActiveRecord::Migration
  def change
    create_table :stranica_bs do |t|
      t.date :b10_1
      t.date :b10_2
      t.decimal :b11, precision: 10, scale: 2
      t.decimal :b12, precision: 10, scale: 2
      t.decimal :b12_1, precision: 10, scale: 2
      t.decimal :b12_2, precision: 10, scale: 2
      t.decimal :b12_3, precision: 10, scale: 2
      t.decimal :b12_4, precision: 10, scale: 2
      t.decimal :b12_5, precision: 10, scale: 2
      t.decimal :b12_6, precision: 10, scale: 2
      t.decimal :b12_7, precision: 10, scale: 2
      t.decimal :b12_8, precision: 10, scale: 2
      t.decimal :b12_9, precision: 10, scale: 2
      t.decimal :b13_1, precision: 10, scale: 2
      t.decimal :b13_2, precision: 10, scale: 2
      t.decimal :b13_3, precision: 10, scale: 2
      t.decimal :b13_4, precision: 10, scale: 2
      t.decimal :b13_5, precision: 10, scale: 2
      t.decimal :b14_1, precision: 10, scale: 2
      t.decimal :b14_2, precision: 10, scale: 2
      t.integer :b15_1
      t.decimal :b15_2, precision: 10, scale: 2
      t.integer :b16_1
      t.decimal :b16_2, precision: 10, scale: 2
      t.decimal :b17, precision: 10, scale: 2

      t.timestamps null: false
    end
  end
end
