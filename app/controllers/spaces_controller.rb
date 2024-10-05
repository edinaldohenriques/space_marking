class SpacesController < ApplicationController
  before_action :set_space, only: %i{show edit update destroy}
  before_action :start_date, only: %i{show}

  def index 
    @q = Space.ransack(params[:q])
    @spaces = @q.result(distinct: true)
  end

  def show
    session[:last_space_id] = @space.id
    
    @reservations = @space.reservations.where(reservation_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
  end

  def new
    @space = Space.new
  end 

  def create 
    @space = Space.new(space_params)

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
    if @space.update(space_params)
      flash[:success] = 'Espaço atualizado com sucesso!'
      redirect_to spaces_path
    else
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def destroy 
    # @space.destroy
    # flash[:success] = 'Espaço excluído com sucesso!'
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
end
