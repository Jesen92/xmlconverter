class GeneratePdfController < ApplicationController
  layout "wicked_pdf"

  def show
    @obrazac = Zaglavlje.find(params[:id])

    @iznos_racun = 0
    @iznos_pdv = 0
    @ukupan_iznos_racuna_s_pdv = 0
    @placeni_iznos_racuna = 0
    @neplaceni_dio_racuna = 0

    @ukupno_iznos_racun = 0
    @ukupno_iznos_pdv = 0
    @ukupno_ukupan_iznos_racuna_s_pdv = 0
    @ukupno_placeni_iznos_racuna = 0
    @ukupno_neplaceni_dio_racuna = 0

    respond_to do |format|
        format.html
        format.pdf do
          render pdf: "file_name" , :template => 'generate_pdf/show.html.erb',  # Excluding ".pdf" extension.
                 orientation: 'Landscape'
        end
      end
  end

end
