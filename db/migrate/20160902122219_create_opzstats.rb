class CreateOpzstats < ActiveRecord::Migration
  def change
    create_table :opzstats do |t|

      t.timestamps null: false
    end
  end
end
