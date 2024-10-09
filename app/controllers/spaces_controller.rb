class SpacesController < ApplicationController
  before_action :set_space, only: %i{show edit update destroy}
  before_action :start_date, only: %i{show}
  before_action :set_action, only: %i{edit update}

  def index
    @q = Space.ransack(params[:q]) # Busca pelo Ransack
    @spaces = @q.result(distinct: true)

    # # Adicionar filtro de shifts manualmente (fora do Ransack)
    # if params[:shifts].present?
    #   @spaces = Space.available_spaces(params[:shifts])
    #   puts "===================================#{@spaces}"
    #   puts Space.available_spaces(params[:shifts]).to_sql

    # end
  end

  def show
    session[:last_space_id] = @space.id

    if params[:my_reservations].present?
      session[:my_reservations] = params[:my_reservations] == '1'
    end

    @my_reservations = session[:my_reservations]
    
    if @my_reservations
      @reservations = @space.reservations.where(user_id: current_user.id, reservation_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
    else 
      @reservations = @space.reservations.where(reservation_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
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
      flash[:success] = 'Espaço cadastrado com sucesso!'
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

  private
    def space_params
      params.require(:space).permit(:name, :description, :board, :laboratory, :projector, :location, :capacity)
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
