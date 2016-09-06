class CreateOpzStat1Xml
  include ActionView::Helpers::NumberHelper

  def initialize(zaglavlje, user)
    @rb = 0
    @rb_racuna = 0

    @ukupan_iznos_racuna_obrasca = 0
    @ukupan_iznos_pdv_obrasca = 0
    @ukupan_iznos_racuna_s_pdv_obrasca = 0
    @ukupno_placeni_iznos = 0
    @ukupno_neplaceni_iznos = 0

    @provjera_kupac_racun = 0

    @zaglavlje = zaglavlje
    @user = user
  end

  def create_opz_stat1_xml
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
            xml.DatumOd @zaglavlje.datum_od
            xml.DatumDo @zaglavlje.datum_do
          }
          xml.PorezniObveznik {
            xml.OIB @zaglavlje.oib
            xml.Naziv @zaglavlje.naziv
            xml.Adresa{
              xml.Mjesto @zaglavlje.mjesto
              xml.Ulica @zaglavlje.ulica
              xml.Broj @zaglavlje.broj
            }
            xml.Email @zaglavlje.email
          }
          xml.IzvjesceSastavio {
            xml.Ime @user.name
            xml.Prezime @user.surname
            xml.Telefon @user.tel
            xml.Fax @user.fax
            xml.Email @user.email
          }
          xml.NaDan @zaglavlje.na_dan
          xml.NisuNaplaceniDo @zaglavlje.nisu_naplaceni_do
        }
        xml.Tijelo {
          @rb = 0
          xml.Kupci {
            @zaglavlje.kupacs.each do |kupac|
              xml.Kupac {
                @kupac_zaglavlje = KupacZaglavlje.find_by(kupac_id: kupac.id, zaglavlje_id: @zaglavlje.id)
                xml.K1 @rb += 1
                xml.K2 @kupac_zaglavlje.oznaka_poreznog_broja
                if @kupac_zaglavlje.oznaka_poreznog_broja == 1
                  if kupac.porezni_broj?
                    @porezni_broj = kupac.porezni_broj.delete(' ')
                  else
                    message = "Kupac "+kupac.naziv_kupca+" u matičnim podacima na sadrži OIB! XML nije kreiran!"
                    return message, false
                  end
                elsif @kupac_zaglavlje.oznaka_poreznog_broja == 2
                  if kupac.pdv_identifikacijski_broj?
                    @porezni_broj = kupac.pdv_identifikacijski_broj.delete(' ')
                  else
                    message = "Kupac "+kupac.naziv_kupca+" u matičnim podacima na sadrži PDV identifikacijski broj! XML nije kreiran!"
                    return message, false
                  end
                else
                  if kupac.ostali_brojevi?
                    @porezni_broj = kupac.ostali_brojevi.delete(' ')
                  else
                    message = "Kupac "+kupac.naziv_kupca+" u matičnim podacima na sadrži ostale brojeve! XML nije kreiran!"
                    return message, false
                  end
                end
                xml.K3 @porezni_broj
                xml.K4 kupac.naziv_kupca
                @rb_racuna = 0
                @iznos_racuna = 0
                @iznos_pdva = 0
                @ukupan_iznos_pdv = 0
                @placeni_iznos = 0
                @neplaceni_iznos = 0
                kupac.racuns.each do |racun|
                  next if racun.zaglavlje_id != @zaglavlje.id
                  @iznos_racuna += racun.iznos_racuna.to_f.round(2)
                  @iznos_pdva += racun.iznos_pdv.to_f.round(2)
                  @placeni_iznos += racun.placeni_iznos_racuna.to_f.round(2)
                  @neplaceni_iznos += (racun.iznos_racuna.to_f.round(2)+racun.iznos_pdv.to_f.round(2)) - racun.placeni_iznos_racuna.to_f.round(2)
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
                  kupac.racuns.each do |racun|
                    next if racun.zaglavlje_id != @zaglavlje.id
                    xml.Racun {
                      xml.R1 @rb_racuna +=1
                      xml.R2 racun.broj_izdanog_racuna
                      xml.R3 racun.datum_izdanog_racuna
                      xml.R4 racun.valuta_placanja_racuna #Date.new(racun["valuta_placanja_racuna(1i)"].to_i, racun["valuta_placanja_racuna(2i)"].to_i, racun["valuta_placanja_racuna(3i)"].to_i)
                      xml.R5 (@zaglavlje.nisu_naplaceni_do - racun.valuta_placanja_racuna).to_i #racun["broj_dana_kasnjenja"]
                      r6 = number_to_currency(racun.iznos_racuna, unit: "", separator: ".", delimiter: "")
                      xml.R6 r6
                      xml.R7 number_to_currency(racun.iznos_pdv, unit: "", separator: ".", delimiter: "")
                      xml.R8 number_to_currency(racun.iznos_racuna.to_f+racun.iznos_pdv.to_f,unit: "", separator: ".", delimiter: "")
                      xml.R9 number_to_currency(racun.placeni_iznos_racuna, unit: "", separator: ".", delimiter: "")
                      xml.R10 number_to_currency((racun.iznos_racuna.to_f.round(2)+racun.iznos_pdv.to_f.round(2)) - racun.placeni_iznos_racuna.to_f.round(2),unit: "", separator: ".", delimiter: "")
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
          xml.OPZUkupanIznosRacunaSPdv !@zaglavlje.opz_ukupan_iznos_racuna_s_pdv.nil? ? number_to_currency(@zaglavlje.opz_ukupan_iznos_racuna_s_pdv, unit: "", separator: ".", delimiter: "") : "0.00" 
          xml.OPZUkupanIznosPdv !@zaglavlje.opz_ukupan_iznos_pdv.nil? ? number_to_currency(@zaglavlje.opz_ukupan_iznos_pdv, unit: "", separator: ".", delimiter: "") : "0.00" #TODO - \\ -
        }
      }

    end

    return builder, true
  end
end