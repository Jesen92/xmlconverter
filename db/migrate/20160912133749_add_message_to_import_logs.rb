class AddMessageToImportLogs < ActiveRecord::Migration
  def change
    add_column :import_logs, :message, :text
  end
end
