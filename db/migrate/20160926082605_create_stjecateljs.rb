class CreateStjecateljs < ActiveRecord::Migration
  def change
    create_table :stjecateljs do |t|
      t.integer :b2
      t.integer :b3
      t.string :b4
      t.string :b5
      t.integer :b6_1
      t.integer :b6_2
      t.integer :b7_1
      t.integer :b7_2
      t.integer :b8
      t.integer :b9
      t.integer :b10

      t.timestamps null: false
    end
  end
end
