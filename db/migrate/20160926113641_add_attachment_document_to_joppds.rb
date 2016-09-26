class AddAttachmentDocumentToJoppds < ActiveRecord::Migration
  def self.up
    change_table :joppds do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :joppds, :document
  end
end
