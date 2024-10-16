class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[edit update destroy]
  before_action :start_date, only: %i[index]
  before_action :set_action, only: %i[edit update]

  def index 
    # @reservations = Reservation.where(reservation_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
  end

  def new 
    @reservation = Reservation.new
  end

  def create
    new_shifts = reservation_params[:shifts] || []
    new_start_date = reservation_params[:start_date]
    new_end_date = reservation_params[:end_date]

    # Verifique se já existe uma reserva que se sobrepõe ao novo intervalo de datas
    existing_reservations = Reservation.for_space(reservation_params[:space_id])
                                       .within_date_range(new_start_date, new_end_date)

    if existing_reservations.by_user(current_user.id).exists? && new_start_date.present? && new_end_date.present? && new_shifts.present?
      # Se a reserva já existe para o usuário atual, atualize os turnos
      existing_reservation = existing_reservations.by_user(current_user.id).first
      conflicting_shifts = Reservation.conflicting_shifts([existing_reservation], new_shifts)

      if conflicting_shifts.any?
        flash[:alert] = "Os turnos já foram reservados: #{Reservation.translate_shifts(conflicting_shifts).join(', ')}"
        redirect_to space_path(existing_reservation.space)
      else
        updated_shifts = Reservation.add_shifts(existing_reservation, new_shifts)

        if existing_reservation.update(shifts: updated_shifts)
          flash[:notice] = "Reserva atualizada com sucesso!"
          redirect_to space_path(existing_reservation.space)
        else
          flash[:alert] = "Erro ao atualizar a reserva."
          respond_to do |format|
            format.turbo_stream
          end
        end
      end
    else
      # Crie uma nova reserva se não houver uma existente
      @reservation = Reservation.new(reservation_params)
      @reservation.user = current_user
      @reservation.shifts = Reservation.sort_shifts(new_shifts)

      if @reservation.save
        flash[:notice] = "Reserva criada com sucesso!"
        redirect_to space_path(@reservation.space)
      else
        respond_to do |format|
          format.turbo_stream
        end
      end
    end
  end

  def edit; end 

  def update
    authorize @reservation  # Verificação de autorização pelo Pundit
  
    new_shifts = reservation_params[:shifts] || []
    new_start_date = reservation_params[:start_date]
    new_end_date = reservation_params[:end_date]
  
    # Buscar reservas no mesmo espaço e com as novas datas (excluindo a reserva atual)
    existing_reservations = Reservation
                              .within_date_range(new_start_date, new_end_date)
                              .for_space(@reservation.space_id)
                              .other_users(current_user.id)
  
    # Verificar se há algum turno já reservado por outras pessoas
    conflicting_shifts = Reservation.conflicting_shifts(existing_reservations, new_shifts)
    conflicting_shifts_translated = Reservation.translate_shifts(conflicting_shifts)
  
    # Se houver conflitos com outras reservas
    if conflicting_shifts.any?
      flash[:alert] = "O turno #{conflicting_shifts_translated.join(', ')} já foi reservado para essas datas por outro usuário."
      redirect_to space_path(@reservation.space)
    else
      # Chamar o método update_reservation para lidar com a lógica de atualização
      if update_reservation(new_start_date, new_end_date, new_shifts, existing_reservations)
        flash[:notice] = "Reserva atualizada com sucesso!"
        redirect_to space_path(@reservation.space)
      else
        flash[:alert] = "Erro ao atualizar a reserva."
        respond_to do |format|
          format.turbo_stream
        end
      end
    end
  end  

  def destroy
    if @reservation.user == current_user || current_user.admin?
      @reservation.destroy!
      redirect_to space_path(@reservation.space)
      flash[:notice] = "Reserva excuída com sucesso!"
    else
      flash[:alert] = "Essa reserva foi realizada por outra pessoa e você tem permissão para alterá-la!"
      redirect_to space_path(@reservation.space)
    end
  end

  private
    def update_reservation(new_start_date, new_end_date, new_shifts, existing_reservations)
      if existing_reservations.by_user(current_user.id).exists?
        existing_reservation = existing_reservations.by_user(current_user.id).first
        updated_shifts = Reservation.add_shifts(existing_reservation, new_shifts)
        return existing_reservation.update(start_date: new_start_date, end_date: new_end_date, shifts: updated_shifts)
      else
        sorted_shifts = Reservation.sort_shifts(new_shifts)
        return @reservation.update(start_date: new_start_date, end_date: new_end_date, shifts: sorted_shifts)
      end
    end

    def reservation_params 
      params.require(:reservation).permit(:start_date, :end_date, :space_id, shifts: [])
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
