class CreateImportLogs < ActiveRecord::Migration
  def change
    create_table :import_logs do |t|
      t.string :message
      t.integer :zaglavlje_id
      t.integer :user_id
      t.boolean :seen

      t.timestamps null: false
    end
  end
end
