class RemoveB2AndB3AndB61AndB62FromStjecateljs < ActiveRecord::Migration
  def change
    remove_column :stjecateljs, :b2, :integer
    remove_column :stjecateljs, :b3, :integer
    remove_column :stjecateljs, :b6_1, :integer
    remove_column :stjecateljs, :b6_2, :integer
  end
end
