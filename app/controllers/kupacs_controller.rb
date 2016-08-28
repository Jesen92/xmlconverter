class KupacsController < ApplicationController
  before_filter :authenticate_user!

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

  private

  def kupac_params
    params.require(:kupac).permit( :id, :naziv_kupca, :porezni_broj, :pdv_identifikacijski_broj, :ostali_brojevi)
  end

end
