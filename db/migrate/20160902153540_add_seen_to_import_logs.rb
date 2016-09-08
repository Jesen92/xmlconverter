class AddSeenToImportLogs < ActiveRecord::Migration
  def change
    add_column :import_logs, :seen, :integer
  end
end
