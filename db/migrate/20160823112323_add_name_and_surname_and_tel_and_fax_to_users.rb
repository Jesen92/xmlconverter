class AddNameAndSurnameAndTelAndFaxToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :surname, :string
    add_column :users, :tel, :string
    add_column :users, :fax, :string
  end
end
