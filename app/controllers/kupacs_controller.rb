class KupacsController < ApplicationController
  before_filter :authenticate_user!

  def import
    @document = Kupac.new
  end

  def import_create

    message, kupac_hash  = Kupac.import_xlsx(params[:kupac][:document], current_user.id)

    if message.include? "Pogreška"
      flash[:alert] = message
      redirect_to(:back)
    else

      if kupac_hash.empty?
        flash[:notice] = "Tablica je uspješno uvezena!"
        redirect_to kupacs_index_path
      else
        flash[:notice] = "Pronađeni su kupci sa istim poreznim brojem, a različitim nazivima!"
        redirect_to kupac_name_conflict_path(kupci: kupac_hash)
      end
    end
  end

  def name_conflict
    @kupacs = Kupac.where(id: params[:kupci].keys)
    @kupac_hash = params[:kupci]
  end

  def update_multiple

    params.each do |key, value|
      next if !key.include? "Kupac"
      kupac = Kupac.find(key.tr('Kupac', ''))
      kupac.naziv_kupca = value[:naziv_kupca]
      kupac.porezni_broj = value[:porezni_broj]
      kupac.pdv_identifikacijski_broj = value[:pdv_identifikacijski_broj]
      kupac.ostali_brojevi = value[:ostali_brojevi]

      kupac.save
    end

    flash[:notice] = "Izmjene su potvrđene!"
    redirect_to kupacs_index_path
  end

  def index
    @kupacs_grid = initialize_grid(Kupac.all, include: [ :user ], order: 'kupacs.created_at', order_direction: 'desc')
  end

  def show
    @kupac = Kupac.find(params[:id])

    @racuns_grid = initialize_grid(@kupac.racuns, include: [ :kupacs, {zaglavlje: :user} ], order: 'racuns.created_at', order_direction: 'desc')
  end

  def new
    @kupac = Kupac.new
  end

  def create
    @poruka = Kupac.check_if_duplicate(params[:kupac])

    if @poruka != false
     flash[:alert] = @poruka
     return redirect_to(:back)
    end

    @kupac = Kupac.new(kupac_params)
    @kupac.user_id = current_user.id
    @kupac.save

    flash[:notice] = "Dodan je novi kupac!"

    redirect_to kupacs_index_path
  end

  def edit
    @kupac = Kupac.find(params[:id])
  end

  def update
    @kupac = Kupac.find(params[:id])
    @kupac.user_id = current_user.id
    @kupac.update(kupac_params)

    flash[:notice] = "Kupac je izmijenjen!"

    redirect_to kupacs_index_path
  end

  def destroy
    @kupac = Kupac.find(params[:id])

    @kupac.destroy

    flash[:notice] = "Kupac je izbrisan!"

    redirect_to kupacs_index_path
  end

  def download_kupci_xlsx
    send_file(
        "#{Rails.root}/public/assets/Sablona_za_dodavanje_kupaca.xlsx",
        filename: "Tablica za dodavanje kupaca.xlsx",
        type: "application/xlsx"
    )
  end

  private

  def kupac_params
    params.require(:kupac).permit( :id, :naziv_kupca, :porezni_broj, :pdv_identifikacijski_broj, :ostali_brojevi)
  end

  def document_params
    params.require(:opzstat).permit(:document)
  end

end
