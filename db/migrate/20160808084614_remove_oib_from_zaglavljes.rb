class RemoveOibFromZaglavljes < ActiveRecord::Migration
  def change
    remove_column :zaglavljes, :oib, :integer
  end
end
