class Zaglavlje < ActiveRecord::Base
  has_paper_trail

  has_one :import_log
  has_one :opzstat

  has_many :kupac_zaglavljes
  has_many :kupacs, :through => :kupac_zaglavljes

  has_many :racuns

  belongs_to :user

  accepts_nested_attributes_for :kupacs, reject_if: :all_blank
  accepts_nested_attributes_for :racuns, reject_if: :all_blank

  def self.import_job(file, user_id)

    PaperTrail.whodunnit = user_id

    message, zaglavlje_id = self.import_xlsx(file, user_id)

    if message.include? "Pogreška"
      #flash[:alert] = message
      if zaglavlje_id != 0
        self.error_destroy(zaglavlje_id)
      end
      puts "Usao u message: "+message
      ImportLog.create(user_id: user_id,message: message, seen: 0)
    else
      ImportLog.create(user_id: user_id,message: message,zaglavlje_id: zaglavlje_id, seen: 0)
      zaglavlje = Zaglavlje.find(zaglavlje_id)
      zaglavlje.created = true
      zaglavlje.save
      file.zaglavlje_id = zaglavlje_id
      file.save
    end
  end

  def self.error_destroy(id)
    @obrazac = Zaglavlje.find(id)
    @racuni = Racun.where(zaglavlje_id: id)

    @racuni.destroy_all
    @obrazac.destroy
  end

  def self.import_xlsx(file, user_id)
    PaperTrail.whodunnit = user_id
    #@svi_kupci = Kupac.all
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

    message, article.nisu_naplaceni_do, article.datum_od, article.datum_do = self.set_attributes_with_na_dan(article)

    if message.include? "Pogreška"
      puts message
      return message, 0
    end

    article.save!
    @zaglavlje_id = article.id
    @kupci = {}

    racuni = spreadsheet.sheet(1) #racuni
    racuni_header = racuni.row(1)

    @error_log = "Racuni"
    (2..racuni.last_row).each do |i|
      @kupac = nil
      @error_red = i.to_s
      row = Hash[[racuni_header, racuni.row(i)].transpose]
      article = Racun.new   #find_by_id(row["id"]) || - ako ce se mijenjati vrijednosti preko excel tablica
      article.attributes = row.to_hash.slice(*row.to_hash.keys)

      #@kupac = Kupac.find_by("porezni_broj = ? OR pdv_identifikacijski_broj = ? OR ostali_brojevi = ?",article.porezni_broj_kupca, article.porezni_broj_kupca, article.porezni_broj_kupca)

      if Kupac.find_by(porezni_broj: article.porezni_broj_kupca)
        @kupac = Kupac.find_by(porezni_broj: article.porezni_broj_kupca)
        @oznaka_poreznog_broja = 1
        puts "Usao1"
      elsif Kupac.find_by(pdv_identifikacijski_broj: article.porezni_broj_kupca)
        @kupac = Kupac.find_by(pdv_identifikacijski_broj: article.porezni_broj_kupca)
        @oznaka_poreznog_broja = 2
        puts "Usao2"
      elsif Kupac.find_by(ostali_brojevi: article.porezni_broj_kupca)
        @kupac = Kupac.find_by(ostali_brojevi: article.porezni_broj_kupca)
        @oznaka_poreznog_broja = 3
        puts "Usao3"
      end

      if @kupac.nil?
        return "Pogreška! Ne postoji kupac u bazi sa poreznim brojem #{article.porezni_broj_kupca}!", @zaglavlje_id
      end

      puts "Ispred KupacZaglavlje: "+@kupac.id.to_s+" kupac"
      if KupacZaglavlje.find_by(kupac_id: @kupac.id, zaglavlje_id: @zaglavlje_id).nil?
        puts "Usao u KupacZaglavlje: "+@kupac.id.to_s+" kupac"
        KupacZaglavlje.create(kupac_id: @kupac.id, zaglavlje_id: @zaglavlje_id, oznaka_poreznog_broja: @oznaka_poreznog_broja)
      end

      article.zaglavlje_id = @zaglavlje_id
      article.save!

      KupacRacun.create(kupac_id: @kupac.id, racun_id: article.id)
    end

    return "Ispravno", @zaglavlje_id.to_s

  rescue => e
    return "Pogreška u listi '#{@error_log}'\nPogreška se nalazi u redu broj #{@error_red} ili u zaglavlju te liste!\nError message: #{e.message}", @zaglavlje_id
  end

  def self.open_spreadsheet(file)
    case File.extname(file.document_file_name)
      when ".csv" then Roo::Csv.new(file.document.url, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.document.url, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.document.url)
      else raise "Unknown file type: #{File.extname(file.document_file_name)}"
    end
  end

  def self.check_if_duplicates(_kupac)
    @kupac = Kupac.find_by("porezni_broj = ? AND porezni_broj IS NOT NULL OR pdv_identifikacijski_broj = ? AND pdv_identifikacijski_broj IS NOT NULL OR ostali_brojevi = ? AND ostali_brojevi IS NOT NULL",_kupac.porezni_broj, _kupac.pdv_identifikacijski_broj, _kupac.ostali_brojevi)

    if @kupac.nil?
      puts "Zapisujem kupca: "+_kupac.naziv_kupca
      return false
    else
      return true
    end
  end

  def self.set_attributes_with_na_dan(article)
    if article.na_dan == Date.new(Date.today.year-1,12,31)
      article.nisu_naplaceni_do = Date.new(Date.today.year,1,31)
      article.datum_od = Date.new(Date.today.year-1, 10, 1)
      article.datum_do = article.na_dan
    elsif article.na_dan == Date.new(Date.today.year,3,31)
      article.nisu_naplaceni_do = Date.new(Date.today.year,4,30)
      article.datum_od = Date.new(Date.today.year, 1, 1)
      article.datum_do = article.na_dan
    elsif article.na_dan == Date.new(Date.today.year,6,30)
      article.nisu_naplaceni_do = Date.new(Date.today.year,7,31)
      article.datum_od = Date.new(Date.today.year, 4, 1)
      article.datum_do = article.na_dan
    elsif article.na_dan == Date.new(Date.today.year,9,30)
      article.nisu_naplaceni_do = Date.new(Date.today.year,10,31)
      article.datum_od = Date.new(Date.today.year, 7, 1)
      article.datum_do = article.na_dan
    elsif article.na_dan == Date.new(Date.today.year,12,31)
      article.nisu_naplaceni_do = Date.new(Date.today.year,1,31)
      article.datum_od = Date.new(Date.today.year, 10, 1)
      article.datum_do = article.na_dan
    else
      return "Pogreška! U listi 'zaglavlje' stupac 'na_dan' nije ispravan!", nil, nil, nil
    end

    return "Ispravno", article.nisu_naplaceni_do, article.datum_od, article.datum_do
  end

end
