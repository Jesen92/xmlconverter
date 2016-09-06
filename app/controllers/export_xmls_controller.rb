class ExportXmlsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_filter :authenticate_user!
  before_filter :check_logs
  respond_to :xml

  require 'nokogiri'
  require 'open-uri'

  #TODO postavi da se excel download-a sa Amazon S3

  def set_notification_seen
    ImportLog.find(params[:id]).update(seen: 1)

    redirect_to(:back)
  end

  ############################################# importiranje excel tablica
  def import
    @document = Opzstat.new
  end

  def import_create

    @document = Opzstat.new( document_params )
    @document.save

    puts "URL: "+@document.document.url
    puts "Path: "+@document.document.path

    Zaglavlje.delay.import_job(@document, current_user.id)

    flash[:notice] = "Podaci se obrađuju! Dobiti će te notifikaciju o statusu izrade obrasca!"
    redirect_to export_xmls_index_path
  end

  #############################################

  def index
    @values_grid = initialize_grid(Zaglavlje.all, include: [ :kupacs, :user, :opzstat ], order: 'zaglavljes.created_at', order_direction: 'desc')
  end

  def show
  end

  def new
    @zaglavlje = Zaglavlje.new

    gon.mycounter = 1
    gon.billcounter = 1
  end

  def create
  end

  def edit
    @zaglavlje = Zaglavlje.find(params[:id])

    gon.mycounter = 1
    gon.billcounter = 1
  end

  def update

    @params = params[:zaglavlje]
    @kupac = params[:zaglavlje][:kupacs_attributes].values

    if params[:subaction] == "Brisanje"
      @obrazac = Zaglavlje.find(params[:zaglavlje]["id"])

      if @obrazac.zakljucano_brisanje?
        @obrazac.zakljucano_brisanje = false
        flash[:notice] = "Obrazac je otključan za brisanje"
      else
        @obrazac.zakljucano_brisanje = true
        flash[:notice] = "Obrazac je zaključan za brisanje"
      end

      @obrazac.save

      return redirect_to(:back)

    elsif params[:subaction] == "Uređivanje"
      @obrazac = Zaglavlje.find(params[:zaglavlje]["id"])

      if @obrazac.zakljucano_uredivanje?
        @obrazac.zakljucano_uredivanje = false
        flash[:notice] = "Obrazac je otključan za uređivanje"
      else
        @obrazac.zakljucano_uredivanje = true
        flash[:notice] = "Obrazac je zaključan za uređivanje"
      end

      @obrazac.save

      return redirect_to(:back)

    elsif params[:subaction] == "Uređivanje/Brisanje"
      @obrazac = Zaglavlje.find(params[:zaglavlje]["id"])

      if @obrazac.zakljucano_uredivanje? && @obrazac.zakljucano_brisanje?
        @obrazac.zakljucano_uredivanje = false
        @obrazac.zakljucano_brisanje = false
        flash[:notice] = "Obrazac je otključan za uređivanje i brisanje"
      else
        @obrazac.zakljucano_uredivanje = true
        @obrazac.zakljucano_brisanje = true
        flash[:notice] = "Obrazac je zaključan za uređivanje i brisanje"
      end

      @obrazac.save

      return redirect_to(:back)

    elsif params[:subaction] != "Snimi Obrazac" && params[:subaction] != "Poslano na poreznu"

      @zaglavlje = Zaglavlje.find(params[:zaglavlje][:id])

      @zaglavlje.kupacs.each do |kupac|

        kupac.racuns.each do |racun|
          if racun.zaglavlje_id == @zaglavlje.id
            @provjera_kupac_racun = 1
            break
          end
        end

          if @provjera_kupac_racun == 0
            flash[:alert] = "Nepravilno ispunjen obrazac!\nProvjerite da li svaki kupac ima barem jedan račun!"
            return redirect_to(:back)
          end
          @provjera_kupac_racun = 0
      end

    #  number_to_currency(1234567890.50, unit: "R$", separator: ",", delimiter: "")
    # => R$1234567890,50

      builder, is_created = CreateOpzStat1Xml.new(@zaglavlje, current_user).create_opz_stat1_xml

      if is_created
        export_myxml(builder)
      else
        flash[:alert] = builder
        redirect_to(:back)
      end

      puts builder.to_xml

      Zaglavlje.find(params[:zaglavlje]["id"]).update(:kreiran_xml => DateTime.now, :korisnik_preuzeo_xml => current_user.name+" "+current_user.surname)

    elsif params[:subaction] == "Poslano na poreznu"

      if Zaglavlje.find(params[:zaglavlje]["id"]).kreiran_xml?

        Zaglavlje.find(params[:zaglavlje]["id"]).update(:poslan_na_poreznu => DateTime.now, :korisnik_porezna => current_user.name+" "+current_user.surname)
        flash[:notice] = "Obrazac označen kao 'Poslan na poreznu'!"
        return redirect_to export_xmls_index_path

      else

        flash[:alert] = "XML obrazac se mora preuzeti prije nego se označi kao 'Poslan na poreznu'!"
        return redirect_to(:back)

      end

    else

        @obrazac = Zaglavlje.new(project_params)
        @obrazac.user_id = current_user.id
        @obrazac.save

        @obrazac.racuns.each do |racun|
          _racun = Racun.find(racun.id)
          _racun.zaglavlje_id = @obrazac.id
          _racun.save
        end

        params[:zaglavlje][:kupacs_attributes].values.each do |kupac|

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

        #TODO izraditi posebnu formu za unos kupaca i izrada nove tablice "Zaglavljes_kupacs" radi optimizaranja baze
        #Kupac.check_duplicate_values() - problem kod postavljanja id-a od racuna i problem jer sadrzi id od zaglavlja

        flash[:notice] = "Obrazac je snimljen!"

      redirect_to export_xmls_edit_path(id: @obrazac.id)
    end


  end

  def destroy
    @obrazac = Zaglavlje.find(params[:id])

    @obrazac.racuns.destroy_all

    @obrazac.destroy

    flash[:notice] = "Obrazac je izbrisan!"

    redirect_to export_xmls_index_path
  end


  def export_myxml(builder)
    send_data(builder.to_xml, filename: 'Obrazac OPZ-'+DateTime.now.strftime("%Y-%m-%d")+'.xml')
  end

  def download_pdf
    send_file(
        "#{Rails.root}/public/assets/OPZ-STAT-1.pdf",
        filename: "Poslovna pravila OPZ-STAT-1 obrasca.pdf",
        type: "application/pdf"
    )
  end

  def download_xlsx
    send_file(
        "#{Rails.root}/public/assets/Sablona_za_nenaplacena_potrazivanja.xlsx",
        filename: "Tablica OPZ-STAT-1.xlsx",
        type: "application/xlsx"
    )
  end
  def download_xlsx_primjer
    send_file(
        "#{Rails.root}/public/assets/Sablona_za_nenaplacena_potrazivanja_primjer-1.xlsx",
        filename: "Tablica OPZ-STAT-1_primjer.xlsx",
        type: "application/xlsx"
    )
  end

  private

  def project_params
    params.require(:zaglavlje).permit( :opz_ukupan_iznos_pdv, :opz_ukupan_iznos_racuna_s_pdv, :created_at, :updated_at,:oib, :naziv, :mjesto, :ulica, :broj, :email, :sastavio_ime, :sastavio_prezime, :sastavio_email, :sastavio_tel, :sastavio_fax ,:description, :datum_od, :datum_do, :na_dan, :nisu_naplaceni_do)

  end

  def kupac_params
    params.require(:zaglavlje).permit(kupacs_attributes: [ racuns_attributes: [:created_at, :updated_at, :iznos_racuna, :iznos_pdv, :placeni_iznos_racuna ,:kupac_id, :broj_izdanog_racuna, :broj_dana_kasnjenja, :datum_izdanog_racuna, :valuta_placanja_racuna]])
  end

  def document_params
    params.require(:opzstat).permit(:document)
  end

  def error_destroy(id)
    @obrazac = Zaglavlje.find(id)
    @racuni = Racun.where(zaglavlje_id: id)

    @racuni.destroy_all
    @obrazac.destroy
  end

end
