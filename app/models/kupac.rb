class Kupac < ActiveRecord::Base
  has_many :racuns
  accepts_nested_attributes_for :racuns, reject_if: :all_blank, allow_destroy: true

  belongs_to :zaglavlje
end
