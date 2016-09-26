class StranicaB < ActiveRecord::Base
  belongs_to :stranica_a

  has_many :stjecateljs_stranica_bs
  has_many :stjecateljs, :through => :stjecateljs_stranica_bs
end
