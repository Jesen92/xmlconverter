class KupacZaglavlje < ActiveRecord::Base
  belongs_to :zaglavlje
  belongs_to :kupac

  accepts_nested_attributes_for :kupac,
                                :reject_if => :all_blank

end
