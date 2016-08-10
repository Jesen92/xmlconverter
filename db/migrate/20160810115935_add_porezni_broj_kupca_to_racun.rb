class AddPorezniBrojKupcaToRacun < ActiveRecord::Migration
  def change
    add_column :racuns, :porezni_broj_kupca, :string
  end
end
