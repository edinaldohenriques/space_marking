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
    # Verifique se já existe uma reserva para a mesma data e espaço
    existing_reservation = Reservation.find_by(
      space_id: reservation_params[:space_id],
      reservation_date: reservation_params[:reservation_date]
    )
  
    if existing_reservation
      # Adicione os novos shifts à reserva existente
      new_shifts = reservation_params[:shifts] || []
  
      # Certifique-se de que não haverá duplicatas ao adicionar novos shifts
      updated_shifts = (existing_reservation.shifts + new_shifts).uniq
  
      # Ordenar os shifts de acordo com a ordem correta (manhã, tarde, noite)
      sorted_shifts = sort_shifts(updated_shifts)
  
      # Atualize os shifts na reserva existente
      if existing_reservation.update(shifts: sorted_shifts)
        flash[:notice] = "Reserva atualizada com sucesso!"
        redirect_to reservations_path
      else
        # Renderizar turbo_stream no caso de erro
        respond_to do |format|
          format.turbo_stream
          redirect_to reservations_path
        end
      end
    else
      # Crie uma nova reserva se não houver uma existente
      @reservation = Reservation.new(reservation_params)
  
      # Ordenar os shifts antes de salvar
      @reservation.shifts = sort_shifts(@reservation.shifts)
  
      if @reservation.save
        flash[:notice] = "Reserva realizada com sucesso!"
        redirect_to reservations_path
      else
        respond_to do |format|
          format.turbo_stream
        end
      end
    end
  end

  def edit; end 

  def update 
    if @reservation.update(reservation_params)
      flash[:notice] = "Reserva atualizada com sucesso!"
      redirect_to reservations_path
    else
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def destroy 
    @reservation.destroy!
    redirect_to reservations_path
    flash[:notice] = "Reserva excuída com sucesso!"
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

    def sort_shifts(shifts)
      # Definir a ordem dos shifts (manhã, tarde, noite)
      valid_shifts_order = ["morning", "afternoon", "evening"]
      shifts.sort_by { |shift| valid_shifts_order.index(shift) }
    end
end
