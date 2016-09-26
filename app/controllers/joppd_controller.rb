class JoppdController < ApplicationController
  def create
  end

  def new
    @stranica_a = StranicaA.new

    gon.mycounter = 1
    gon.billcounter = 1
  end

  def update
  end

  def edit
  end

  def show
  end

  def index
  end

  def destroy
    flash[:notice] = "Obrazac je izbrisan!"

    redirect_to
  end

  def import
  end

  def import_create
  end

  def set_notification_seen
  end

  def export_myxml
  end

  def download_xlsx
  end

  def download_xlsx_primjer
  end

  private

  def stranica_a_params
    params.require(:stranica_a).permit(:vrsta_izvjesca, :naziv, :mjesto, :ulica, :broj, :email, :oib, :oznaka_podnositelja, :user_id, stranica_bs_attributes: [ :stjecatelj_id, :b10_1, :b10_2, :b11, :b12, :b12_1, :b12_2, :b12_3, :b12_4, :b12_5, :b12_6, :b12_7, :b12_8, :b12_9, :b13_1, :b13_2, :b13_3, :b13_4, :b13_5, :b14_1, :b14_2, :b15_1, :b15_2, :b16_1, :b16_2, :b17])
  end

  def stranica_b_params

  end
end
