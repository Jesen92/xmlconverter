class Zaglavlje < ActiveRecord::Base
  has_many :kupacs
  accepts_nested_attributes_for :kupacs, allow_destroy: true
end
