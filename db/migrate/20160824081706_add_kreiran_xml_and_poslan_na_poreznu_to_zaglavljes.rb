class AddKreiranXmlAndPoslanNaPoreznuToZaglavljes < ActiveRecord::Migration
  def change
    add_column :zaglavljes, :kreiran_xml, :datetime
    add_column :zaglavljes, :poslan_na_poreznu, :datetime
  end
end
