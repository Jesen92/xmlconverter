class AddB2AndB3AndB61AndB62ToStjecateljs < ActiveRecord::Migration
  def change
    add_column :stjecateljs, :b2, :string
    add_column :stjecateljs, :b3, :string
    add_column :stjecateljs, :b6_1, :string
    add_column :stjecateljs, :b6_2, :string
  end
end
