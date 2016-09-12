class RemoveMessageFromImportLogs < ActiveRecord::Migration
  def change
    remove_column :import_logs, :message, :string
  end
end
