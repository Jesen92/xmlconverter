class AddPdvIdentifikacijskiBrojAndOstaliBrojeviToKupacs < ActiveRecord::Migration
  def change
    add_column :kupacs, :pdv_identifikacijski_broj, :string
    add_column :kupacs, :ostali_brojevi, :string
  end
end
