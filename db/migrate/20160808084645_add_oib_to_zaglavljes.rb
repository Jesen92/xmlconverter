class AddOibToZaglavljes < ActiveRecord::Migration
  def change
    add_column :zaglavljes, :oib, :integer, :limit => 8
  end
end
