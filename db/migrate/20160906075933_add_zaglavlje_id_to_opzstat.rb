class AddZaglavljeIdToOpzstat < ActiveRecord::Migration
  def change
    add_column :opzstats, :zaglavlje_id, :integer
  end
end
