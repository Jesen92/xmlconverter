class Kupac < ActiveRecord::Base
  has_many :kupac_zaglavljes
  has_many :zaglavljes, :through => :kupac_zaglavljes
  accepts_nested_attributes_for :zaglavljes, reject_if: :all_blank

  has_many :kupac_racuns
  has_many :racuns, :through => :kupac_racuns
  accepts_nested_attributes_for :racuns, reject_if: :all_blank, allow_destroy: true

  belongs_to :user

  validates :naziv_kupca, :porezni_broj, presence: true

  def self.check_duplicate_values
    grouped = all.group_by{|model| [model.porezni_broj] }

    grouped.values.each do |duplicates|
      first_one = duplicates.shift

      duplicates.each{|double| double.destroy} #duplikati se brišu
    end

  end

  def self.check_if_duplicate(params)

    puts "Porezni broj:"+params[:porezni_broj]

    all.each do |kupac|
      if kupac.porezni_broj == params[:porezni_broj]
        return "U bazi postoji kupac sa istim OIB-om! Kupac nije spremljen!"
      elsif !kupac.pdv_identifikacijski_broj.nil? && kupac.pdv_identifikacijski_broj == params[:pdv_identifikacijski_broj]
        return "U bazi postoji kupac sa istim pdv identifikacijskim brojem! Kupac nije spremljen!"
      elsif !kupac.ostali_brojevi.nil? && kupac.ostali_brojevi == params[:ostali_brojevi]
        return "U bazi postoji kupac sa istim ostalim brojevima! Kupac nije spremljen!"
      end
    end

    return false
  end

end
