class StranicaA < ActiveRecord::Base
  has_many :stranica_bs

  accepts_nested_attributes_for :stranica_bs, reject_if: :all_blank
end
