class Zaglavlje < ActiveRecord::Base
  has_many :kupac_zaglavljes
  has_many :kupacs, :through => :kupac_zaglavljes

  has_many :racuns

  belongs_to :user

  accepts_nested_attributes_for :kupacs, reject_if: :all_blank
  accepts_nested_attributes_for :racuns, reject_if: :all_blank

  def self.import_xlsx(file, user_id)
    @svi_kupci = Kupac.all
    puts "usao je u import_xlsx"
    @zaglavlje_id = 0

    spreadsheet = open_spreadsheet(file)

    zaglavlje = spreadsheet.sheet(0) #zaglavlje
    zaglavlje_header = zaglavlje.row(1)

    @error_log = "Zaglavlje"
    @error_red = "1"
    row = Hash[[zaglavlje_header, zaglavlje.row(zaglavlje.last_row)].transpose]
    article = new   #find_by_id(row["id"]) || - ako ce se mijenjati vrijednosti preko excel tablica
    article.attributes = row.to_hash.slice(*row.to_hash.keys)
    article.user_id = user_id
    article.save!
    @zaglavlje_id = article.id
    @kupci = {}

    kupci = spreadsheet.sheet(1) #kupci
    kupci_header = kupci.row(1)

    @error_log = "Kupci"
    (2..kupci.last_row).each do |i|
      @error_red = i.to_s
      row = Hash[[kupci_header, kupci.row(i)].transpose]

      article = Kupac.new   #find_by_id(row["id"]) || - ako ce se mijenjati vrijednosti preko excel tablica
      article.attributes = row.to_hash.slice(*row.to_hash.keys)

      next if !self.check_if_duplicates(@svi_kupci ,article)

      article.zaglavlje_id = @zaglavlje_id #postavljanje id-a od kreiranog zaglavlja

      article.save!
      if article.porezni_broj != nil
        @kupci[article.porezni_broj] = article.id
      elsif article.pdv_identifikacijski_broj != nil
        @kupci[article.pdv_identifikacijski_broj] = article.id
      elsif article.ostali_brojevi != nil
        @kupci[article.ostali_brojevi] = article.id
      end
    end

    racuni = spreadsheet.sheet(2) #racuni
    racuni_header = racuni.row(1)

    @error_log = "Racuni"
    (2..racuni.last_row).each do |i|
      @error_red = i.to_s
      row = Hash[[racuni_header, racuni.row(i)].transpose]
      article = Racun.new   #find_by_id(row["id"]) || - ako ce se mijenjati vrijednosti preko excel tablica
      article.attributes = row.to_hash.slice(*row.to_hash.keys)

      @kupac = Kupac.find_by("porezni_broj = ? OR pdv_identifikacijski_broj = ? OR ostali_brojevi = ?",article.porezni_broj_kupca, article.porezni_broj_kupca, article.porezni_broj_kupca)

      if @kupac.porezni_broj == article.porezni_broj_kupca
        @kupac = Kupac.find_by(porezni_broj: article.porezni_broj_kupca)
        @oznaka_poreznog_broja = 1
        puts "Usao1"
      elsif @kupac.pdv_identifikacijski_broj == article.porezni_broj_kupca
        @kupac = Kupac.find_by(pdv_identifikacijski_broj: article.porezni_broj_kupca)
        @oznaka_poreznog_broja = 2
        puts "Usao2"
      elsif @kupac.ostali_brojevi == article.porezni_broj_kupca
        @kupac = Kupac.find_by(ostali_brojevi: article.porezni_broj_kupca)
        @oznaka_poreznog_broja = 3
        puts "Usao3"
      end

      if @kupac.nil?
        return "Pogreška! Ne postoji kupac u bazi sa poreznim brojem #{article.porezni_broj_kupca}!", @zaglavlje_id
      end

      if KupacZaglavlje.where(kupac_id: @kupac.id, zaglavlje_id: @zaglavlje_id).empty?
        KupacZaglavlje.create(kupac_id: @kupac.id, zaglavlje_id: @zaglavlje_id, oznaka_poreznog_broja: @oznaka_poreznog_broja)
      end

      article.zaglavlje_id = @zaglavlje_id
      article.save!

      KupacRacun.create(kupac_id: @kupac.id, racun_id: article.id)
    end

    return "Ispravno", @zaglavlje_id.to_s

  #rescue => e
  #  return "Pogreška u listi '#{@error_log}'\nPogreška se nalazi u redu broj #{@error_red} ili u zaglavlju te liste!\nError message: #{e.message}", @zaglavlje_id
  end

  def self.open_spreadsheet(file)

    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{File.extname(file)}"
    end
  end

  def self.check_if_duplicates(svi_kupci ,_kupac)

    svi_kupci.each do |kupac|
      if kupac.porezni_broj != nil && kupac.porezni_broj == _kupac.porezni_broj
        return false
      elsif kupac.pdv_identifikacijski_broj != nil && kupac.pdv_identifikacijski_broj == _kupac.pdv_identifikacijski_broj
        return false
      elsif kupac.ostali_brojevi != nil &&  kupac.ostali_brojevi == _kupac.ostali_brojevi
        return false
      end
    end

    puts "Zapisujem kupca: "+_kupac.naziv_kupca
    true
  end


end
