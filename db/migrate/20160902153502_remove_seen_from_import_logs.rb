class RemoveSeenFromImportLogs < ActiveRecord::Migration
  def change
    remove_column :import_logs, :seen, :boolean
  end
end
