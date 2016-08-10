class Kupac < ActiveRecord::Base
  has_many :racuns
  accepts_nested_attributes_for :racuns, reject_if: :all_blank, allow_destroy: true

  belongs_to :zaglavlje

  def self.check_duplicate_values
    grouped = all.group_by{|model| [model.porezni_broj] }

    grouped.values.each do |duplicates|
      first_one = duplicates.shift

      duplicates.each{|double| double.destroy} #duplikati se brišu
    end

  end

end
