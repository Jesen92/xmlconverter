class ExportXmlsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_filter :authenticate_user!
  respond_to :xml

  require 'nokogiri'
  require 'open-uri'

  ############################################# importiranje excel tablica
  def import
    @document = FileUpload.new
  end

  def import_create

    puts "Orginalno ime je: #{params[:file_upload][:document]}"

    message, zaglavlje_id = Zaglavlje.import_xlsx(params[:file_upload][:document], current_user.id)

    if message.include? "Pogreška"
      flash[:alert] = message
      if zaglavlje_id != 0
        error_destroy(zaglavlje_id)
      end
      redirect_to(:back)
    else
      flash[:notice] = "XLSX tablica je uspješno uvezena i obrazac je spremljen!"
      redirect_to export_xmls_edit_path(id: zaglavlje_id.to_i)
    end


  end
  #############################################

  def index
    @values_grid = initialize_grid(Zaglavlje.all, include: [ :kupacs, :user ], order: 'zaglavljes.created_at', order_direction: 'desc')
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
    @rb = 0
    @rb_racuna = 0

    @ukupan_iznos_racuna_obrasca = 0
    @ukupan_iznos_pdv_obrasca = 0
    @ukupan_iznos_racuna_s_pdv_obrasca = 0
    @ukupno_placeni_iznos = 0
    @ukupno_neplaceni_iznos = 0

    @provjera_kupac_racun = 0
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

      @kupac.each do |kupac|
        kupac["racuns_attributes"].values.each do |racun|
          next if racun["_destroy"] == "1"
          @provjera_kupac_racun = 1
        end

        if @provjera_kupac_racun == 0
          flash[:alert] = "Nepravilno ispunjen obrazac!\nProvjerite da li svaki kupac ima barem jedan račun!"
          return redirect_to(:back)
        end
        @provjera_kupac_racun = 0
      end
    #  number_to_currency(1234567890.50, unit: "R$", separator: ",", delimiter: "")
    # => R$1234567890,50

    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.ObrazacOPZ('verzijaSheme' => "1.0", 'xmlns' => "http://e-porezna.porezna-uprava.hr/sheme/zahtjevi/ObrazacOPZ/v1-0") {
        xml.Metapodaci('xmlns' => "http://e-porezna.porezna-uprava.hr/sheme/Metapodaci/v2-0") {
          xml.Naslov('dc' => "http://purl.org/dc/elements/1.1/title") { xml.text "Obrazac OPZ"}
          xml.Autor( 'dc' => "http://purl.org/dc/elements/1.1/creator") { xml.text "KORISNIK 2EP" }
          xml.Datum( 'dc' => "http://purl.org/dc/elements/1.1/date") {xml.text DateTime.now.strftime("%Y-%m-%dT%H:%M:%S").to_s}
          xml.Format( 'dc' => "http://purl.org/dc/elements/1.1/format") {xml.text "text/xml"}
          xml.Jezik( 'dc'=>"http://purl.org/dc/elements/1.1/language"){ xml.text "hr-HR"}
          xml.Identifikator( 'dc'=>"http://purl.org/dc/elements/1.1/identifier") { xml.text SecureRandom.uuid.to_s}
          xml.Uskladjenost( 'dc'=>"http://purl.org/dc/terms/conformsTo") { xml.text "ObrazacOPZ-v1-0"}
          xml.Tip( 'dc'=>"http://purl.org/dc/elements/1.1/type"){ xml.text "Elektronički obrazac"}
          xml.Adresant "Ministarstvo Financija, Porezna uprava, Zagreb"
        }
        xml.Zaglavlje {
          xml.Razdoblje {
            xml.DatumOd Date.new(@params["datum_od(1i)"].to_i, @params["datum_od(2i)"].to_i, @params["datum_od(3i)"].to_i).strftime("%Y-%m-%d")
            xml.DatumDo Date.new(@params["datum_do(1i)"].to_i, @params["datum_do(2i)"].to_i ,@params["datum_do(3i)"].to_i).strftime("%Y-%m-%d")
          }
          xml.PorezniObveznik {
            xml.OIB @params[:oib]
            xml.Naziv @params[:naziv]
            xml.Adresa{
              xml.Mjesto @params[:mjesto]
              xml.Ulica @params[:ulica]
              xml.Broj @params[:broj]
            }
            xml.Email @params[:email]
          }
          xml.IzvjesceSastavio {
          xml.Ime current_user.name
          xml.Prezime current_user.surname
          xml.Telefon current_user.tel
          xml.Fax current_user.fax
          xml.Email current_user.email
          }
          xml.NaDan Date.new(@params["na_dan(1i)"].to_i, @params["na_dan(2i)"].to_i, @params["na_dan(3i)"].to_i )
          @nisu_naplaceni_do = Date.new(@params["nisu_naplaceni_do(1i)"].to_i, @params["nisu_naplaceni_do(2i)"].to_i, @params["nisu_naplaceni_do(3i)"].to_i)
          xml.NisuNaplaceniDo @nisu_naplaceni_do #Date.new(@params["nisu_naplaceni_do(1i)"].to_i, @params["nisu_naplaceni_do(2i)"].to_i, @params["nisu_naplaceni_do(3i)"].to_i)
        }
        xml.Tijelo {
          @rb = 0
          xml.Kupci {
          @kupac.each do |kupac|
            xml.Kupac {
              xml.K1 @rb += 1
              xml.K2 kupac["oznaka_poreznog_broja"]
              xml.K3 kupac["porezni_broj"]
              xml.K4 kupac["naziv_kupca"]
              @rb_racuna = 0
              @iznos_racuna = 0
              @iznos_pdva = 0
              @ukupan_iznos_pdv = 0
              @placeni_iznos = 0
              @neplaceni_iznos = 0
              kupac["racuns_attributes"].values.each do |racun|
                next if racun["_destroy"] == "1"
                @iznos_racuna += racun["iznos_racuna"].gsub(",", ".").to_f.round(2)
                @iznos_pdva += racun["iznos_pdv"].gsub(",", ".").to_f.round(2)
                @placeni_iznos += racun["placeni_iznos_racuna"].gsub(",", ".").to_f.round(2)
                @neplaceni_iznos += (racun["iznos_racuna"].gsub(",", ".").to_f.round(2)+racun["iznos_pdv"].gsub(",", ".").to_f.round(2)) - racun["placeni_iznos_racuna"].to_f.round(2)
              end
              @ukupan_iznos_pdv = @iznos_racuna+@iznos_pdva
              xml.K5 number_to_currency(@iznos_racuna, unit: "", separator: ".", delimiter: "")
              xml.K6 number_to_currency(@iznos_pdva, unit: "", separator: ".", delimiter: "")
              xml.K7 number_to_currency(@ukupan_iznos_pdv, unit: "", separator: ".", delimiter: "")
              xml.K8 number_to_currency(@placeni_iznos, unit: "", separator: ".", delimiter: "")
              xml.K9 number_to_currency(@neplaceni_iznos, unit: "", separator: ".", delimiter: "")
              @ukupan_iznos_racuna_obrasca += @iznos_racuna #ukupni iznosi
              @ukupan_iznos_pdv_obrasca += @iznos_pdva
              @ukupan_iznos_racuna_s_pdv_obrasca += @ukupan_iznos_pdv
              @ukupno_placeni_iznos += @placeni_iznos
              @ukupno_neplaceni_iznos += @neplaceni_iznos
              xml.Racuni {
                kupac["racuns_attributes"].values.each do |racun|
                  next if racun["_destroy"] == "1"
                  xml.Racun {
                    xml.R1 @rb_racuna +=1
                    xml.R2 racun["broj_izdanog_racuna"]
                    xml.R3 Date.new(racun["datum_izdanog_racuna(1i)"].to_i, racun["datum_izdanog_racuna(2i)"].to_i, racun["datum_izdanog_racuna(3i)"].to_i)
                    valuta_placanja_racuna = Date.new(racun["datum_izdanog_racuna(1i)"].to_i, racun["datum_izdanog_racuna(2i)"].to_i, racun["datum_izdanog_racuna(3i)"].to_i)
                    xml.R4 valuta_placanja_racuna #Date.new(racun["valuta_placanja_racuna(1i)"].to_i, racun["valuta_placanja_racuna(2i)"].to_i, racun["valuta_placanja_racuna(3i)"].to_i)
                    xml.R5 (@nisu_naplaceni_do - valuta_placanja_racuna).to_i #racun["broj_dana_kasnjenja"]
                    r6 = number_to_currency(racun["iznos_racuna"], unit: "", separator: ".", delimiter: "")
                    xml.R6 r6
                    xml.R7 number_to_currency(racun["iznos_pdv"].gsub(",", "."), unit: "", separator: ".", delimiter: "")
                    xml.R8 number_to_currency(racun["iznos_racuna"].gsub(",", ".").to_f+racun["iznos_pdv"].gsub(",", ".").to_f,unit: "", separator: ".", delimiter: "")
                    xml.R9 number_to_currency(racun["placeni_iznos_racuna"].gsub(",", "."), unit: "", separator: ".", delimiter: "")
                    xml.R10 number_to_currency((racun["iznos_racuna"].gsub(",", ".").to_f.round(2)+racun["iznos_pdv"].gsub(",", ".").to_f.round(2)) - racun["placeni_iznos_racuna"].gsub(",", ".").to_f.round(2),unit: "", separator: ".", delimiter: "")
                  }
                end
              }
            }
          end
          }
          xml.UkupanIznosRacunaObrasca number_to_currency(@ukupan_iznos_racuna_obrasca, unit: "", separator: ".", delimiter: "")
          xml.UkupanIznosPdvObrasca number_to_currency(@ukupan_iznos_pdv_obrasca, unit: "", separator: ".", delimiter: "")
          xml.UkupanIznosRacunaSPdvObrasca number_to_currency(@ukupan_iznos_racuna_s_pdv_obrasca, unit: "", separator: ".", delimiter: "")
          xml.UkupniPlaceniIznosRacunaObrasca number_to_currency(@ukupno_placeni_iznos, unit: "", separator: ".", delimiter: "")
          xml.NeplaceniIznosRacunaObrasca number_to_currency(@ukupno_neplaceni_iznos, unit: "", separator: ".", delimiter: "")
          xml.OPZUkupanIznosRacunaSPdv !params[:zaglavlje]["opz_ukupan_iznos_racuna_s_pdv"].nil? ? number_to_currency(params[:zaglavlje]["opz_ukupan_iznos_racuna_s_pdv"].gsub(",", "."), unit: "", separator: ".", delimiter: "") : "0.00" #TODO upit u poreznu za što je to pošto nije pojašnjeno u dokumentaciji
          xml.OPZUkupanIznosPdv !params[:zaglavlje]["opz_ukupan_iznos_pdv"].nil? ? number_to_currency(params[:zaglavlje]["opz_ukupan_iznos_pdv"].gsub(",", "."), unit: "", separator: ".", delimiter: "") : "0.00" #TODO - \\ -
        }
      }

    end

      export_myxml(builder)

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

        #TODO izraditi posebnu formu za unos kupaca i izrada nove tablice "Zaglavljes_kupacs" radi optimizaranja baze
        #Kupac.check_duplicate_values() - problem kod postavljanja id-a od racuna i problem jer sadrzi id od zaglavlja

        flash[:notice] = "Obrazac je snimljen!"

      redirect_to export_xmls_edit_path(id: @obrazac.id)
    end


  end

  def destroy
    @obrazac = Zaglavlje.find(params[:id])
    @kupci = Kupac.where(zaglavlje_id: params[:id])
    @racuni = Racun.where(kupac_id: @kupci.ids)

    @kupci.destroy_all
    @racuni.destroy_all
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
    params.require(:zaglavlje).permit( :opz_ukupan_iznos_pdv, :opz_ukupan_iznos_racuna_s_pdv, :created_at, :updated_at,:oib, :naziv, :mjesto, :ulica, :broj, :email, :sastavio_ime, :sastavio_prezime, :sastavio_email, :sastavio_tel, :sastavio_fax ,:description, :datum_od, :datum_do, :na_dan, :nisu_naplaceni_do,
                                       kupacs_attributes: [ :oznaka_poreznog_broja, :porezni_broj, :naziv_kupca, :zaglavlje_id, :creted_at, :updated_at ,:_destroy,
                                       racuns_attributes: [:created_at, :updated_at, :iznos_racuna, :iznos_pdv, :placeni_iznos_racuna ,:kupac_id, :broj_izdanog_racuna, :broj_dana_kasnjenja, :datum_izdanog_racuna, :valuta_placanja_racuna, :_destroy]])
  end



  def error_destroy(id)
    @obrazac = Zaglavlje.find(id)
    @kupci = Kupac.where(zaglavlje_id: id)
    @racuni = Racun.where(kupac_id: @kupci.ids)

    @kupci.destroy_all
    @racuni.destroy_all
    @obrazac.destroy
  end

end
