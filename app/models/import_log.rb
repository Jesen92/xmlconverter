class ImportLog < ActiveRecord::Base
  belongs_to :zaglavlje
  belongs_to :user
end
