class GeneratePdfController < ApplicationController
  before_filter :authenticate_user!
  layout "wicked_pdf"

  def show
    @obrazac = Zaglavlje.find(params[:id])
    @page_break_count = 0

    @iznos_racuna = 0.00
    @iznos_pdv = 0.00
    @ukupan_iznos_racuna_s_pdv = 0.00
    @placeni_iznos_racuna = 0.00
    @neplaceni_dio_racuna = 0.00

    @ukupno_iznos_racuna = 0.00
    @ukupno_iznos_pdv = 0.00
    @ukupno_ukupan_iznos_racuna_s_pdv = 0.00
    @ukupno_placeni_iznos_racuna = 0.00
    @ukupno_neplaceni_dio_racuna = 0.00

    @rb_kupca = 1
    @rb_racuna = 1

    respond_to do |format|
        format.html
        format.pdf do
          render pdf: "OPZ-STAT-1 Izvješće "+@obrazac.created_at.strftime("%d.%m.%Y") , :template => 'generate_pdf/show.html.erb',  # Excluding ".pdf" extension.
                 orientation: 'Landscape'
        end
    end

  rescue => e
    flash[:alert] = "Pogreška kod kreiranja izvješća! Provjerite da li su sva polja u obrascu pravilno ispunjena!\nError message: #{e.message}"
    redirect_to(:back)
  end

end
