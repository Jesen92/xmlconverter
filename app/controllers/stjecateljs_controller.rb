class StjecateljsController < ApplicationController
  def create
    @stjecatelj = Stjecatelj.new(stjecatelj_params)
    @stjecatelj.user_id = current_user.id
    @stjecatelj.save

    flash[:notice] = "Stjecatelj je kreiran!"

    redirect_to stjecateljs_index_path
  end

  def new
    @stjecatelj = Stjecatelj.new
  end

  def update
    @stjecatelj = Stjecatelj.find(params[:id])
    @stjecatelj.user_id = current_user.id
    @stjecatelj.updated_at = Time.now
    @stjecatelj.assign_attributes(stjecatelj_params)
    @stjecatelj.save

    flash[:notice] = "Stjecatelj je izmijenjen!"

    redirect_to stjecateljs_index_path
  end

  def edit
    @stjecatelj = Stjecatelj.find(params[:id])
  end

  def show
  end

  def index
    @stjecateljs_grid = initialize_grid(Stjecatelj.all, include: [ :user ], order: 'stjecateljs.created_at', order_direction: 'desc')
  end

  def destroy
    @stjecatelj = Stjecatelj.find(params[:id])
    @stjecatelj.destroy

    flash[:notice] = "Stjecatelj je izbrisan!"

    redirect_to stjecateljs_index_path
  end

  def import
    @document = Stjecatelj.new
  end

  def import_create
    message  = Stjecatelj.import_xlsx(params[:stjecatelj][:document], current_user.id)

    if message.include? "Pogreška"
      flash[:alert] = message
      redirect_to(:back)
    else
      flash[:notice] = "Tablica je uspješno uvezena!"
      redirect_to stjecateljs_index_path
    end
  end

  def download_xlsx
    send_file(
        "#{Rails.root}/public/assets/Sablona_za_uvoz_stjecatelja.xlsx",
        filename: "Tablica za dodavanje stjecatelja.xlsx",
        type: "application/xlsx"
    )
  end

  def download_xlsx_primjer
    send_file(
        "#{Rails.root}/public/assets/Sablona_za_uvoz_stjecatelja_primjer.xlsx",
        filename: "Primjer tablice za dodavanje stjecatelja.xlsx",
        type: "application/xlsx"
    )
  end

  private

  def stjecatelj_params
    params.require(:stjecatelj).permit(:b2, :b3, :b4, :b5, :b6_1, :b6_2, :b7_1, :b7_2, :b8, :b9, :b10)
  end
end
