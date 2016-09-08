class AddCreatedToZaglavljes < ActiveRecord::Migration
  def change
    add_column :zaglavljes, :created, :boolean
  end
end
