class SpacesController < ApplicationController
  before_action :set_space, only: %i[show edit update destroy toggle_status reservation_history]
  before_action :start_date, only: %i[show]
  before_action :set_action, only: %i[edit update]

  def index
    @q = Space.ransack(params[:q]) # Busca pelo Ransack
    current_user.admin? ? @spaces = @q.result.order(:name) : @spaces = @q.result.where(active: true).order(:name) 
  end

  def show
    session[:last_space_id] = @space.id

    if params[:my_reservations].present?
      session[:my_reservations] = params[:my_reservations] == '1'
    end

    @my_reservations = session[:my_reservations]
    
    if @my_reservations
      @reservations = @space.reservations.where(user_id: current_user.id, start_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
    else 
      @reservations = @space.reservations.where(start_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
    end
  end

  def reservation_history
    start_date = params[:start_date]
    end_date = params[:end_date]

    if start_date.present? && end_date.present?
      @reservations_history = Reservation.by_date_range(start_date, end_date).order(:start_date)
    else
      @reservations_history = []
    end
  
    respond_to do |format|
      format.html { redirect_to space_path(@space.id) }
      format.pdf do
        render pdf: 'histórico-reservas',
              template: 'spaces/reservation_history',
              # disposition: 'attachment',                  # default 'inline'
              # show_as_html: params.key?('debug'),
              page_size: 'A4'
      end
    end
  end

  def new
    @space = Space.new
    authorize @space
  end 

  def create 
    @space = Space.new(space_params)
    authorize @space

    if @space.save 
      flash[:notice] = 'Espaço cadastrado com sucesso!'
      redirect_to spaces_path
    else
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def edit; end 

  def update  
    authorize @space

    if @space.update(space_params)
      flash[:notice] = 'Espaço atualizado com sucesso!'
      redirect_to spaces_path
    else
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def destroy 
    authorize @space
    @space.destroy
    flash[:notice] = 'Espaço excluído com sucesso!'
    redirect_to spaces_path
  end

  def toggle_status   
    # Alterna o status do espaço (ativo/desativado)
    @space.update!(active: !@space.active)
  end

  private
    def space_params
      params.require(:space).permit(:name, :description, :board, :laboratory, :projector, :accessibility, :location, :capacity, :floor)
    end

    def set_space
      @space = Space.find(params[:id])
    end

    def start_date
      params.fetch(:start_date, Date.today).to_date
    end

    def set_action
      @action = 'edit'
    end
end
