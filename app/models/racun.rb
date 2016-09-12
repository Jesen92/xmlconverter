class Racun < ActiveRecord::Base

  has_many :kupac_racuns
  has_many :kupacs, :through => :kupac_racuns
  accepts_nested_attributes_for :kupacs, reject_if: :all_blank, allow_destroy: true

  belongs_to :zaglavlje
end
