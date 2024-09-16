class SpacesController < ApplicationController
  before_action :set_space, only: %i[show edit update destroy]

  def index 
    @spaces = Space.order(:name)
  end

  def show; end

  def new
    @space = Space.new
  end 

  def create 
    @space = Space.new(space_params)

    if @space.save 
      flash[:success] = 'Espaço cadastrado com sucesso!'
      redirect_to spaces_path
    else
      render 'new'
    end
  end

  def edit; end 

  def update  
    if @space.update(space_params)
      flash[:success] = 'Espaço atualizado com sucesso!'
      redirect_to spaces_path
    else
      render 'edit'
    end
  end

  def destroy 
    @space.destroy
    flash[:success] = 'Espaço excluído com sucesso!'
    redirect_to spaces_path
  end

  private
    def space_params
      params.require(:space).permit(:name, :description, :board, :laboratory, :projector, :location, :capacity)
    end

    def set_space
      @space = Space.find(params[:id])
    end
end
