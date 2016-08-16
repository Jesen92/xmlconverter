class Zaglavlje < ActiveRecord::Base
  has_many :kupacs
  accepts_nested_attributes_for :kupacs, allow_destroy: true

  def self.import_xlsx(file)
    puts "usao je u import_xlsx"

    spreadsheet = open_spreadsheet(file)

    zaglavlje = spreadsheet.sheet(0) #zaglavlje
    zaglavlje_header = zaglavlje.row(1)

    @error_log = "Zaglavlje"
    @error_red = "1"
    row = Hash[[zaglavlje_header, zaglavlje.row(zaglavlje.last_row)].transpose]
    article = new   #find_by_id(row["id"]) || - ako ce se mijenjati vrijednosti preko excel tablica
    article.attributes = row.to_hash.slice(*row.to_hash.keys)
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
      article.zaglavlje_id = @zaglavlje_id #postavljanje id-a od kreiranog zaglavlja

      article.save!
      @kupci[article.porezni_broj] = article.id
    end

    racuni = spreadsheet.sheet(2) #racuni
    racuni_header = racuni.row(1)

    @error_log = "Racuni"
    (2..racuni.last_row).each do |i|
      @error_red = i.to_s
      row = Hash[[racuni_header, racuni.row(i)].transpose]
      article = Racun.new   #find_by_id(row["id"]) || - ako ce se mijenjati vrijednosti preko excel tablica
      article.attributes = row.to_hash.slice(*row.to_hash.keys)

      article.kupac_id = @kupci[article.porezni_broj_kupca]

      article.save!
    end

    @zaglavlje_id.to_s

  rescue
    return "Pogreška u listi << #{@error_log} >> Pogreška se nalazi u redu broj #{@error_red} ili u zaglavlju te liste!"
  end

  def self.open_spreadsheet(file)

    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{File.extname(file)}"
    end
  end



end
