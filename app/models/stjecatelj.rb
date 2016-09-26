class Stjecatelj < ActiveRecord::Base
  has_paper_trail

  belongs_to :user

  has_many :stjecateljs_stranica_bs
  has_many :stranica_bs, :through => :stjecateljs_stranica_bs

  def self.import_xlsx(file, user_id)
    PaperTrail.whodunnit = user_id

    spreadsheet = open_spreadsheet(file)

    stjecatelji = spreadsheet.sheet(0) #stjecatelji
    stjecatelji_header = stjecatelji.row(1)

    (2..stjecatelji.last_row).each do |i|
      @error_red = i.to_s
      row = Hash[[stjecatelji_header, stjecatelji.row(i)].transpose]

      stjecatelj = Stjecatelj.new   #find_by_id(row["id"]) || - ako ce se mijenjati vrijednosti preko excel tablica
      stjecatelj.attributes = row.to_hash.slice(*row.to_hash.keys)

      isDuplicate = self.check_if_duplicates(stjecatelj)

      next if isDuplicate

      stjecatelj.user_id = user_id
      stjecatelj.save!
    end

    return "Ispravno"

  rescue => e
    return "Pogreška!\nPogreška se nalazi u redu broj #{@error_red}\nError message: #{e.message}"
  end

  def self.check_if_duplicates(stjecatelj)
    Stjecatelj.find_by(b4: stjecatelj.b4).nil? ? false : true
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
