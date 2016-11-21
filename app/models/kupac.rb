class Kupac < ActiveRecord::Base
  has_paper_trail

  has_many :kupac_zaglavljes
  has_many :zaglavljes, :through => :kupac_zaglavljes
  accepts_nested_attributes_for :zaglavljes, reject_if: :all_blank

  has_many :kupac_racuns
  has_many :racuns, :through => :kupac_racuns
  accepts_nested_attributes_for :racuns, reject_if: :all_blank, allow_destroy: true

  belongs_to :user


  validates :naziv_kupca, presence: true

  def self.import_xlsx(file, user_id)
    PaperTrail.whodunnit = user_id

    kupac_hash = {}

    spreadsheet = open_spreadsheet(file)
    kupci = spreadsheet.sheet(0) #kupci
    kupci_header = kupci.row(1)

    (2..kupci.last_row).each do |i|
      @error_red = i.to_s
      row = Hash[[kupci_header, kupci.row(i)].transpose]

      kupac = Kupac.new   #find_by_id(row["id"]) || - ako ce se mijenjati vrijednosti preko excel tablica
      kupac.attributes = row.to_hash.slice(*row.to_hash.keys)

      isDuplicate, naziv_kupca = self.check_if_duplicates(kupac)

      puts "Naziv kupca: "+naziv_kupca[0].to_s

      if naziv_kupca[0] == nil
        puts "Postavljam kupac_hash"
        kupac_hash = kupac_hash.merge(naziv_kupca)
      end

      next if isDuplicate

      kupac.user_id = user_id
      kupac.save!
    end

    return "Ispravno", kupac_hash

  #rescue => e
  #  return "Pogreška!\nPogreška se nalazi u redu broj #{@error_red} ili u zaglavlju!\nError message: #{e.message}", nil
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{File.extname(file)}"
    end
  end

  def self.check_if_duplicates(_kupac)
    @kupac = Kupac.find_by("porezni_broj = ? AND porezni_broj IS NOT NULL OR pdv_identifikacijski_broj = ? AND pdv_identifikacijski_broj IS NOT NULL OR ostali_brojevi = ? AND ostali_brojevi IS NOT NULL",_kupac.porezni_broj, _kupac.pdv_identifikacijski_broj, _kupac.ostali_brojevi)

    if @kupac.nil?
      puts "Zapisujem kupca: "+_kupac.naziv_kupca
      return false, { 0 => "1"}
    else
      if @kupac.naziv_kupca == _kupac.naziv_kupca
        return true, { 0 => "1"}
      else
        puts "Nije isti!"
        return true, { @kupac.id => _kupac.naziv_kupca}
      end
    end
  end

  def self.check_if_duplicate_create(params)
    kupci = Kupac.all
    puts "Porezni broj:"+params[:porezni_broj]

    kupci.each do |kupac|
      if kupac.porezni_broj != '' && kupac.porezni_broj == params[:porezni_broj]
        return "U bazi postoji kupac sa istim OIB-om! Kupac nije spremljen!"
      elsif kupac.pdv_identifikacijski_broj != '' && kupac.pdv_identifikacijski_broj == params[:pdv_identifikacijski_broj]
        return "U bazi postoji kupac sa istim pdv identifikacijskim brojem! Kupac nije spremljen!"
      elsif kupac.ostali_brojevi != '' && kupac.ostali_brojevi == params[:ostali_brojevi]
        return "U bazi postoji kupac sa istim ostalim brojevima! Kupac nije spremljen!"
      end
    end

    return false
  end

end
