class CreateOpzStat1
  def initialize(params, user_id)
    @user_id = user_id
    @params = params
  end

  def create_opz_stat1

    @obrazac = Zaglavlje.new(@params.require(:zaglavlje).permit( :opz_ukupan_iznos_pdv, :opz_ukupan_iznos_racuna_s_pdv, :created_at, :updated_at,:oib, :naziv, :mjesto, :ulica, :broj, :email, :sastavio_ime, :sastavio_prezime, :sastavio_email, :sastavio_tel, :sastavio_fax ,:description, :datum_od, :datum_do, :na_dan, :nisu_naplaceni_do))
    @obrazac.user_id = @user_id

    if @obrazac.na_dan == Date.new(Date.today.year-1,12,31)
      @obrazac.nisu_naplaceni_do = Date.new(Date.today.year,1,31)
      @obrazac.datum_od = Date.new(Date.today.year-1, 10, 1)
      @obrazac.datum_do = @obrazac.na_dan
    elsif @obrazac.na_dan == Date.new(Date.today.year,3,31)
      @obrazac.nisu_naplaceni_do = Date.new(Date.today.year,4,30)
      @obrazac.datum_od = Date.new(Date.today.year, 1, 1)
      @obrazac.datum_do = @obrazac.na_dan
    elsif @obrazac.na_dan == Date.new(Date.today.year,6,30)
      @obrazac.nisu_naplaceni_do = Date.new(Date.today.year,7,31)
      @obrazac.datum_od = Date.new(Date.today.year, 4, 1)
      @obrazac.datum_do = @obrazac.na_dan
    elsif @obrazac.na_dan == Date.new(Date.today.year,9,30)
      @obrazac.nisu_naplaceni_do = Date.new(Date.today.year,10,31)
      @obrazac.datum_od = Date.new(Date.today.year, 7, 1)
      @obrazac.datum_do = @obrazac.na_dan
    elsif @obrazac.na_dan == Date.new(Date.today.year,12,31)
      @obrazac.nisu_naplaceni_do = Date.new(Date.today.year,1,31)
      @obrazac.datum_od = Date.new(Date.today.year, 10, 1)
      @obrazac.datum_do = @obrazac.na_dan
    end

    @obrazac.save

    @obrazac.racuns.each do |racun|
      _racun = Racun.find(racun.id)
      _racun.zaglavlje_id = @obrazac.id
      _racun.save
    end

    @params[:zaglavlje][:kupacs_attributes].values.each do |kupac|

      next if kupac["_destroy"] == "1"

      @kupac_zaglavlje = KupacZaglavlje.new()


      puts "Id od kupca je "+kupac[:id]

      @kupac_zaglavlje.kupac_id = kupac[:id]
      @kupac_zaglavlje.zaglavlje_id = @obrazac.id
      @kupac_zaglavlje.oznaka_poreznog_broja = kupac[:oznaka_poreznog_broja]
      @kupac_zaglavlje.save

      kupac[:racuns_attributes].values.each do |racun|
        next if racun["_destroy"] == "1"
        next if racun[:broj_izdanog_racuna] == nil

        @kupac_racun = KupacRacun.new()

        @racun = Racun.new(racun.except(:id,:_destroy))
        @racun.zaglavlje_id = @obrazac.id

        @racun.save

        @kupac_racun.racun_id = @racun.id
        @kupac_racun.kupac_id = kupac[:id]
        @kupac_racun.save


      end

    end
    ImportLog.create(message: "Ispravno", zaglavlje_id: @obrazac.id, user_id: @user_id, seen: 0)

  rescue => e
    ImportLog.create(message: "Pogreška kod kreiranja obrasca!\nPoruka pogreška: #{e.message}",user_id: @user_id, seen: 0)
    destroy(@obrazac.id)
  end

  def project_params(params)
    params.require(:zaglavlje).permit( :opz_ukupan_iznos_pdv, :opz_ukupan_iznos_racuna_s_pdv, :created_at, :updated_at,:oib, :naziv, :mjesto, :ulica, :broj, :email, :sastavio_ime, :sastavio_prezime, :sastavio_email, :sastavio_tel, :sastavio_fax ,:description, :datum_od, :datum_do, :na_dan, :nisu_naplaceni_do)
  end

  def kupac_params(params)
    params.require(:zaglavlje).permit(kupacs_attributes: [ racuns_attributes: [:created_at, :updated_at, :iznos_racuna, :iznos_pdv, :placeni_iznos_racuna ,:kupac_id, :broj_izdanog_racuna, :broj_dana_kasnjenja, :datum_izdanog_racuna, :valuta_placanja_racuna]])
  end

  def destroy(obrazac_id)
    @obrazac = Zaglavlje.find(obrazac_id)

    @obrazac.racuns.destroy_all

    @obrazac.destroy
  end
end