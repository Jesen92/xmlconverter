class ExportXmlsController < ApplicationController
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
  end

  def destroy
  end


  private

  def project_params
    params.require(:zaglavlje).permit(:name, :description, kupac_attributes: [:id, :_destroy])
  end

end
