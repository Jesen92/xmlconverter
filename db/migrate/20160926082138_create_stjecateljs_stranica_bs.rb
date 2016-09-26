class CreateStjecateljsStranicaBs < ActiveRecord::Migration
  def change
    create_table :stjecateljs_stranica_bs do |t|
      t.integer :stjecatelj_id
      t.integer :stranica_b_id

      t.timestamps null: false
    end
  end
end
