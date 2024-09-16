class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i{edit update destroy}
  before_action :start_date, only: %i{index}
  before_action :set_action, only: %i{edit update}

  def index 
    @reservations = Reservation.where(reservation_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
  end

  def new 
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(reservation_params)
  
    if @reservation.save
      flash[:notice] = "Reserva realizada com sucesso!"
      redirect_to reservations_path
    else
      # render :new, status: :unprocessable_entity
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to reservations_url, notice: 'User was successfully destroyed.' }
      end
    end
  end

  def edit; end 

  def update 
    if @reservation.update(reservation_params)
      flash[:notice] = "Reserva realizada com sucesso!"
      redirect_to reservations_path
    else
      
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def destroy 
  end

  private
    def reservation_params 
      params.require(:reservation).permit(:reservation_date, :space_id, :user_id, shifts: [])
    end

    def set_reservation 
      @reservation = Reservation.find(params[:id])
    end

    def start_date
      params.fetch(:start_date, Date.today).to_date
    end

    def set_action
      @action = 'edit'
    end
end
