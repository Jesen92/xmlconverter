class AddAttachmentDocumentToOpzstats < ActiveRecord::Migration
  def self.up
    change_table :opzstats do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :opzstats, :document
  end
end
