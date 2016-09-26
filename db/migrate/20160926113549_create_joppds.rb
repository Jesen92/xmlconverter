class CreateJoppds < ActiveRecord::Migration
  def change
    create_table :joppds do |t|
      t.integer :stranica_a_id

      t.timestamps null: false
    end
  end
end
