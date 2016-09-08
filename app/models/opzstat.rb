class Opzstat < ActiveRecord::Base
  belongs_to :zaglavlje

  has_attached_file :document

  validates_attachment :document, presence: true,
                       content_type: { content_type: [
                           "application/vnd.ms-excel",
                           "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                       ]
                       },
                       message: 'Dopuštene su samo EXCEL datoteke!'

end
