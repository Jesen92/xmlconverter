class AddOznakaPoreznogBrojaToKupacZaglavljes < ActiveRecord::Migration
  def change
    add_column :kupac_zaglavljes, :oznaka_poreznog_broja, :integer
  end
end
