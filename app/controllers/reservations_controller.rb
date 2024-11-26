class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[edit update destroy approve cancel]
  before_action :set_action, only: %i[edit update]
  after_action :verify_authorized, only: [:approve, :cancel]

  def new 
    start_date = params[:start_date]
    end_date = params[:end_date]
    @reservation = Reservation.new(start_date: start_date, end_date: end_date)  
  end

  def create
    new_shifts = reservation_params[:shifts] || []
    new_start_date = reservation_params[:start_date]
    new_end_date = reservation_params[:end_date]

    # Busque reservas existentes para o mesmo espaço dentro do intervalo de datas
    existing_reservations = Reservation
                                      .for_space(reservation_params[:space_id])
                                      .within_date_range(new_start_date, new_end_date)
                                      .by_user(current_user.id)

    if existing_reservations.exists? && new_start_date.present? && new_end_date.present? && new_shifts.present?
      existing_reservation = existing_reservations.first
      
      # Verifique se as datas da nova reserva são exatamente iguais à reserva existente
      if existing_reservation.start_date == new_start_date && existing_reservation.end_date == new_end_date
        # Se as datas coincidirem, verifique o conflito de turnos
        conflicting_shifts = Reservation.conflicting_shifts([existing_reservation], new_shifts)

        if conflicting_shifts.any?
          flash[:alert] = "Os turnos já foram reservados: #{Reservation.translate_shifts(conflicting_shifts).join(', ')}"
          redirect_to space_path(existing_reservation.space)
        else
          # Adicione novos turnos à reserva existente
          updated_shifts = Reservation.add_shifts(existing_reservation, new_shifts)

          if existing_reservation.update(shifts: updated_shifts)
            flash[:notice] = "Reserva atualizada com sucesso!"
            redirect_to space_path(existing_reservation.space)
          else
            respond_to do |format|
              format.turbo_stream
            end
          end
        end
      else
        # Se as datas forem diferentes, crie uma nova reserva
        @reservation = Reservation.new(reservation_params)
        @reservation.user = current_user unless reservation_params[:user_id].present? 

        if @reservation.save
          if current_user.admin? 
            @reservation.update(status: "confirmed")
            flash[:notice] = "Reserva realizada com sucesso!"
            redirect_to space_path(@reservation)
          else
            NotifyAdminJob.perform_later(User.admins.first)
            flash[:notice] = "Reserva solicitada com sucesso!"
            redirect_to space_path(@reservation)
          end
        else
          respond_to do |format|
            format.turbo_stream
          end
        end
      end
    else
      # Caso não exista reserva no intervalo de datas, crie uma nova reserva
      @reservation = Reservation.new(reservation_params)
      @reservation.user = current_user unless reservation_params[:user_id].present? 

      if @reservation.save
        if current_user.admin? 
          @reservation.update(status: "confirmed")
          NotifyApproveReservationUserJob.perform_later(@reservation.user)
          flash[:notice] = "Reserva realizada com sucesso!"
          redirect_to space_path(@reservation)
        else
          NotifyAdminJob.perform_later(User.admins.first)
          flash[:notice] = "Reserva solicitada com sucesso!"
          redirect_to space_path(@reservation)
        end
      else
        respond_to do |format|
          format.turbo_stream
        end
      end
    end
  end

  def edit; end 

  def update
    authorize @reservation

    new_shifts = reservation_params[:shifts] || []
    new_start_date = reservation_params[:start_date]
    new_end_date = reservation_params[:end_date]

    # Buscar reservas conflitantes no mesmo espaço e no intervalo de datas (excluindo a reserva atual)
    conflicting_reservations = Reservation
                              .within_date_range(new_start_date, new_end_date)
                              .for_space(@reservation.space_id)
                              .where.not(id: @reservation.id)

    # Verificar se há turnos conflitantes com outras reservas para o intervalo de datas
    conflicting_shifts = Reservation.conflicting_shifts(conflicting_reservations, new_shifts)
    conflicting_shifts_translated = Reservation.translate_shifts(conflicting_shifts)

    # Impedir a atualização se houver conflito, seja usuário comum ou admin
    if conflicting_shifts.any?
      flash[:alert] = "O turno #{conflicting_shifts_translated.join(', ')} já foi reservado para essas datas por outro usuário."
      redirect_to space_path(@reservation)
    else
      # Caso não haja conflito, procedemos com a atualização
      if update_reservation(new_start_date, new_end_date, new_shifts, conflicting_reservations)
        if current_user.admin?
          NotifyUpdateReservationUserJob.perform_later(@reservation.user)
          flash[:notice] = "Reserva atualizada com sucesso!"
          redirect_to space_path(@reservation)
        else
          @reservation.update(status: "pending")          
          NotifyAdminJob.perform_later(User.admins.first)
          flash[:notice] = "Reserva solicitada com sucesso!"
          redirect_to space_path(@reservation)
        end
      else
        flash[:alert] = "Erro ao atualizar a reserva."
        respond_to do |format|
          format.turbo_stream
        end
      end
    end
  end

  def destroy
    authorize @reservation
    @reservation.destroy!
    redirect_to space_path(@reservation)
    flash[:notice] = "Reserva excuída com sucesso!"
  end

  def pending_reservation 
    @pending_reservations = Reservation.where(status: 0).order(:start_date) 
    if @pending_reservations.empty?
      flash[:notice] = "Você não possui nenhuma reserva pendente!"
      redirect_to spaces_path
    end
  end

  def approve
    authorize @reservation, :approve?
    if @reservation.update(status: :confirmed)
      NotifyApproveReservationUserJob.perform_later(@reservation.user)
      flash.now[:notice] = "Reserva aprovada com sucesso."
    else
      flash.now[:alert] = "Não foi possível aprovar a reserva."
    end
  end

  def cancel
    authorize @reservation, :cancel? 
    if @reservation.update(status: :cancelled)
      NotifyCancelReservationUserJob.perform_later(@reservation.user)
      @reservation.destroy
      flash.now[:notice] = "Reserva cancelada e removida com sucesso."
    else
      flash.now[:alert] = "Não foi possível cancelar a reserva."
    end
  end

  private
    def update_reservation(new_start_date, new_end_date, new_shifts, existing_reservations)
      if existing_reservations.by_user(current_user.id).exists?
        existing_reservation = existing_reservations.by_user(current_user.id).first
        updated_shifts = Reservation.add_shifts(existing_reservation, new_shifts)
        return existing_reservation.update(start_date: new_start_date, end_date: new_end_date, shifts: updated_shifts)
      else
        @reservation.update(start_date: new_start_date, end_date: new_end_date, shifts: new_shifts)
      end
    end

    def reservation_params 
      params.require(:reservation).permit(:start_date, :end_date, :space_id, :user_id, :booking_information, shifts: [])
    end

    def set_reservation 
      @reservation = Reservation.find(params[:id])
    end

    def set_action
      @action = 'edit'
    end
end
