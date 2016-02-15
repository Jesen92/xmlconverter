class ExportXmlsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  respond_to :xml

  require 'nokogiri'
  require 'open-uri'

  def index
  end

  def show
  end

  def new
    @zaglavlje = Zaglavlje.new
  end

  def create
  end

  def edit
  end

  def update
    @rb = 0
    @rb_racuna = 0

    @ukupan_iznos_racuna_obrasca = 0
    @ukupan_iznos_pdv_obrasca = 0
    @ukupan_iznos_racuna_s_pdv_obrasca = 0
    @ukupno_placeni_iznos = 0
    @ukupno_neplaceni_iznos = 0

    @params = params[:zaglavlje]
    @kupac = params[:zaglavlje][:kupacs_attributes].values


    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.ObrazacOPZ('verzijaSheme' => "1.0", 'xmlns' => "http://e-porezna.porezna-uprava.hr/sheme/zahtjevi/ObrazacOPZ/v1-0") {
        xml.Metapodaci('xmlns' => "http://e-porezna.porezna-uprava.hr/sheme/Metapodaci/v2-0") {
          xml.Naslov('dc' => "http://purl.org/dc/elements/1.1/title") { xml.text "Obrazac OPZ"}
          xml.Autor( 'dc' => "http://purl.org/dc/elements/1.1/creator") { xml.text "KORISNIK 2EP" }
          xml.Datum( 'dc' => "http://purl.org/dc/elements/1.1/date") {xml.text "2015-11-23T15:02:51"}
          xml.Format( 'dc' => "http://purl.org/dc/elements/1.1/format") {xml.text "text/xml"}
          xml.Jezik( 'dc'=>"http://purl.org/dc/elements/1.1/language"){ xml.text "hr-HR"}
          xml.Identifikator( 'dc'=>"http://purl.org/dc/elements/1.1/identifier") { xml.text "0577ee9b-0a03-4719-b308-016fd70d4cb2"}
          xml.Uskladjenost( 'dc'=>"http://purl.org/dc/terms/conformsTo") { xml.text "ObrazacOPZ-v1-0"}
          xml.Tip( 'dc'=>"http://purl.org/dc/elements/1.1/type"){ xml.text "Elektronički obrazac"}
          xml.Adresant "Ministarstvo Financija, Porezna uprava, Zagreb"
        }
        xml.Zaglavlje {
          xml.Razdoblje {
            xml.DatumOd @params["datum_od(1i)"]+"-"+@params["datum_od(2i)"]+"-"+@params["datum_od(3i)"]
            xml.DatumDo @params["datum_do(1i)"]+"-"+@params["datum_do(2i)"]+"-"+@params["datum_do(3i)"]
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
          xml.Ime @params[:sastavio_ime]
          xml.Prezime @params[:sastavio_prezime]
          xml.Telefon @params[:sastavio_tel]
          xml.Fax @params[:sastavio_fax]
          xml.Email @params[:sastavio_email]
          }
          xml.NaDan @params["na_dan(1i)"]+"-"+@params["na_dan(2i)"]+"-"+@params["na_dan(3i)"]
          xml.NisuNaplaceniDo @params["nisu_naplaceni_do(1i)"]+"-"+@params["nisu_naplaceni_do(2i)"]+"-"+@params["nisu_naplaceni_do(3i)"]
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
              xml.Racuni {
                @rb_racuna = 0
                @iznos_racuna = 0
                @iznos_pdva = 0
                @ukupan_iznos_pdv = 0
                @placeni_iznos = 0
                @neplaceni_iznos = 0
                kupac["racuns_attributes"].values.each do |racun|
                  xml.Racun {
                    @iznos_racuna += racun["iznos_racuna"].to_f.round(2)
                    @iznos_pdva += racun["iznos_pdv"].to_f.round(2)
                    @placeni_iznos += racun["placeni_iznos_racuna"].to_f.round(2)
                    @neplaceni_iznos += (racun["iznos_racuna"].to_f.round(2)+racun["iznos_pdv"].to_f.round(2)) - racun["placeni_iznos_racuna"].to_f.round(2)
                    @placeni_iznos += racun["placeni_iznos_racuna"].to_f.round(2)
                    @ukupan_iznos_pdv = racun["iznos_racuna"].to_f.round(2)+racun["iznos_pdv"].to_f.round(2)
                    xml.R1 @rb_racuna +=1
                    xml.R2 racun["broj_izdanog_racuna"]
                    xml.R3 racun["datum_izdanog_racuna(1i)"]+"-"+racun["datum_izdanog_racuna(2i)"]+"-"+racun["datum_izdanog_racuna(3i)"]
                    xml.R4 racun["valuta_placanja_racuna(1i)"]+"-"+racun["valuta_placanja_racuna(2i)"]+"-"+racun["valuta_placanja_racuna(3i)"]
                    xml.R5 racun["broj_dana_kasnjenja"]
                    r6 = number_to_currency(racun["iznos_racuna"], unit: "")
                    xml.R6 r6
                    xml.R7 number_to_currency(racun["iznos_pdv"], unit: "")
                    xml.R8 number_to_currency(racun["iznos_racuna"].to_f+racun["iznos_pdv"].to_f,unit: "")
                    xml.R9 number_to_currency(racun["placeni_iznos_racuna"], unit: "")
                    xml.R10 number_to_currency((racun["iznos_racuna"].to_f.round(2)+racun["iznos_pdv"].to_f.round(2)) - racun["placeni_iznos_racuna"].to_f.round(2),unit: "", separator: ".")
                  }
                  @ukupan_iznos_racuna_obrasca += @iznos_racuna
                  @ukupan_iznos_pdv_obrasca += @iznos_pdva
                  @ukupan_iznos_racuna_s_pdv_obrasca += @ukupan_iznos_pdv
                  @ukupno_placeni_iznos += @placeni_iznos
                  @ukupno_neplaceni_iznos += @neplaceni_iznos
                end
              }
              xml.K5 number_to_currency(@iznos_racuna, unit: "")
              xml.K6 number_to_currency(@iznos_pdva, unit: "")
              xml.K7 number_to_currency(@ukupan_iznos_pdv, unit: "")
              xml.K8 number_to_currency(@placeni_iznos, unit: "")
              xml.K9 number_to_currency(@neplaceni_iznos, unit: "")
            }
          end
          }
          xml.UkupanIznosRacunaObrasca number_to_currency(@ukupan_iznos_racuna_obrasca, unit: "")
          xml.UkupanIznosPdvObrasca number_to_currency(@ukupan_iznos_pdv_obrasca, unit: "")
          xml.UkupanIznosRacunaSPdvObrasca number_to_currency(@ukupan_iznos_racuna_s_pdv_obrasca, unit: "")
          xml.UkupniPlaceniIznosRacunaObrasca number_to_currency(@ukupno_placeni_iznos, unit: "")
          xml.NeplaceniIznosRacunaObrasca number_to_currency(@ukupno_neplaceni_iznos, unit: "")
          xml.OPZUkupanIznosRacunaSPdv "0.00"
          xml.OPZUkupanIznosPdv "0.00"
        }
      }

    end

    export_myxml(builder)

    puts builder.to_xml


  end

  def destroy
  end


  def export_myxml(builder)
    send_data(builder.to_xml, filename: 'Obrazac OPS.xml')
  end

  private

  def project_params
    params.require(:zaglavlje).permit(:name, :description, kupac_attributes: [:id, :_destroy])
  end

end
