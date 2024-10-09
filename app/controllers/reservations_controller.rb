class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i{edit update destroy}
  before_action :start_date, only: %i{index}
  before_action :set_action, only: %i{edit update}
  # before_action :authenticate_user!

  def index 
    # @reservations = Reservation.where(reservation_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
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
  
    if existing_reservation && existing_reservation.user == current_user

      # Adicione os novos shifts à reserva existente
      new_shifts = reservation_params[:shifts] || []

      conflicting_shifts = existing_reservation.shifts & new_shifts

      if existing_reservation.reservation_date.to_s && conflicting_shifts.any? 
        flash[:alert] = "O turno já foi reservado para esta data"
        redirect_to space_path(existing_reservation.space)
      else 
        # Certifique-se de que não haverá duplicatas ao adicionar novos shifts
        updated_shifts = (existing_reservation.shifts + new_shifts).uniq
  
        # Ordenar os shifts de acordo com a ordem correta (manhã, tarde, noite)
        sorted_shifts = sort_shifts(updated_shifts)
    
        # Atualize os shifts na reserva existente
        if existing_reservation.update(shifts: sorted_shifts)
          flash[:notice] = "Reserva atualizada com sucesso!"
          redirect_to space_path(existing_reservation.space)
        else
          redirect_to space_path(existing_reservation.space)
          flash[:alert] = "O turno já foi reservado"
        end
      end
    else
      # Crie uma nova reserva se não houver uma existente
      @reservation = Reservation.new(reservation_params)
      @reservation.user = current_user # Associar a reserva ao usuário atual
  
      # Ordenar os shifts antes de salvar
      @reservation.shifts = sort_shifts(@reservation.shifts)
  
      if @reservation.save
        flash[:notice] = "Reserva realizada com sucesso!"
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
    new_shifts = reservation_params[:shifts] || []
    new_date = reservation_params[:reservation_date]
  
    # Encontrar a reserva existente na nova data
    existing_reservation = Reservation.where(reservation_date: new_date).order(:created_at).first
    verify_existing_reservations = Reservation.where(reservation_date: new_date)
    # shifts_user_reservation = Reservation.where(reservation_date: "2024-10-29", shifts: ["morning"]).order(:created_at).first
  
    if verify_existing_reservations && existing_reservation
      # Verificar se há algum turno já reservado
      conflicting_shifts = verify_existing_reservations.map(&:shifts).flatten & new_shifts

      verify_other_reservations = verify_existing_reservations.where.not(user_id: current_user.id )
      conflicting_shifts_in_other_reservations = verify_other_reservations.map(&:shifts).flatten & new_shifts
      
      conflicting_shifts_translated = conflicting_shifts.map { |shift| I18n.t("activerecord.attributes.reservation.shifts.#{shift}") }

      # Se houver conflitos de turnos e a data for diferente da original
      if new_date != @reservation.reservation_date.to_s && conflicting_shifts.any?  || new_date == @reservation.reservation_date.to_s && (@reservation.user == current_user || current_user.admin?) && (verify_existing_reservations.count > 1 && conflicting_shifts_in_other_reservations.any?)
        flash[:alert] = "O turno #{conflicting_shifts_translated.join(', ')} já foi reservado para esta data"
        redirect_to space_path(@reservation.space)
      elsif new_date == @reservation.reservation_date.to_s && (@reservation.user == current_user || current_user.admin?) # && verify_existing_reservations.count == 1 # !conflicting_shifts.any?
        # # Atualizar a reserva sem mudar a data
        if @reservation.update(reservation_params)
          flash[:notice] = "Reserva atualizada com sucesso!"
          redirect_to space_path(@reservation.space)
        else
          flash[:alert] = "Erro ao atualizar a reserva."
          respond_to do |format|
            format.turbo_stream
          end
        end
      elsif new_date != @reservation.reservation_date.to_s && (existing_reservation.user == current_user || current_user.admin?)
        if current_user.admin?
          sorted_shifts = sort_shifts(new_shifts)
          if @reservation.update(reservation_date: new_date, shifts: sorted_shifts)
            flash[:notice] = "Reserva atualizada com sucesso!"
            redirect_to space_path(existing_reservation.space)
          else
            flash[:alert] = "Erro ao atualizar a reserva."
            respond_to do |format|
              format.turbo_stream
            end
          end
        else
          # Atualizar para uma nova data
          updated_shifts = (existing_reservation.shifts + new_shifts).uniq
          sorted_shifts = sort_shifts(updated_shifts)
    
          if existing_reservation.update(reservation_date: new_date, shifts: sorted_shifts)
            # Excluir a reserva antiga
            @reservation.destroy
    
            flash[:notice] = "Reserva atualizada com sucesso!"
            redirect_to space_path(existing_reservation.space)
          else
            flash[:alert] = "Erro ao atualizar a reserva."
            respond_to do |format|
              format.turbo_stream
            end
          end
        end
      elsif new_date != @reservation.reservation_date.to_s && (existing_reservation.user != current_user || current_user.admin?)
        sorted_shifts = sort_shifts(new_shifts)
  
        if @reservation.update(reservation_date: new_date, shifts: sorted_shifts)
          flash[:notice] = "Reserva atualizada com sucesso!"
          redirect_to space_path(existing_reservation.space)
        else
          flash[:alert] = "Erro ao atualizar a reserva."
          respond_to do |format|
            format.turbo_stream
          end
        end
      else
        flash[:alert] = "Essa reserva foi realizada por outra pessoa e você tem permissão para alterá-la!"
        redirect_to space_path(existing_reservation.space)
      end
    elsif @reservation.user == current_user || current_user.admin?
      if @reservation.update(reservation_params)
        flash[:notice] = "Reserva atualizada com sucesso!"
        redirect_to space_path(@reservation.space)
      else
        flash[:alert] = "Erro ao atualizar a reserva."
        respond_to do |format|
          format.turbo_stream
        end
      end
    else
      flash[:alert] = "Essa reserva foi realizada por outra pessoa e você tem permissão para alterá-la!"
      redirect_to space_path(@reservation.space)
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
    def reservation_params 
      params.require(:reservation).permit(:reservation_date, :space_id, shifts: [])
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
