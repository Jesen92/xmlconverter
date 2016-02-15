class CreateOutputs < ActiveRecord::Migration
  def change
    create_table :outputs do |t|
      t.text :za_output

      t.timestamps null: false
    end
  end
end
