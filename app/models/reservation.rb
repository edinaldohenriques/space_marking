class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :space

  validates :start_date, presence: true, start_date: { message: 'não pode ser anterior ao dia de hoje' }, on: :create
  validates :end_date, presence: true, end_date: { message: 'não pode ser menor a Data Inicial' }
  validates :shifts, presence: { message: 'O turno não pode ficar em branco' }
  validate :validate_unique_shifts, on: :create 


  # Escopos para consultas comuns
  scope :within_date_range, ->(start_date, end_date) { where("start_date <= ? AND end_date >= ?", end_date, start_date) if start_date.present? && end_date.present? }
  scope :for_space, ->(space_id) { where(space_id: space_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :other_users, ->(user_id) { where.not(user_id: user_id) }
  scope :with_shifts, ->(shifts) { where("shifts && ARRAY[?]::varchar[]", shifts) } # Verifica a interseção dos turnos

  # Traduzir turnos (para exibir mensagens amigáveis ao usuário)
  def self.translate_shifts(shifts)
    shifts.map { |shift| I18n.t("activerecord.attributes.reservation.shifts.#{shift}") }
  end

  # Método para verificar se há conflitos de turnos entre uma nova reserva e as existentes
  def self.conflicting_shifts(existing_reservations, new_shifts)
    existing_reservations.map(&:shifts).flatten & new_shifts
  end

  # Método para adicionar turnos a uma reserva existente, garantindo que não haja duplicatas
  def self.add_shifts(existing_reservation, new_shifts)
    (existing_reservation.shifts + new_shifts).uniq
  end

  # Método para verificar se uma reserva colide com as datas e turnos de outra
  def self.check_conflicts(new_start_date, new_end_date, new_shifts, space_id, user_id)
    # Buscando reservas existentes dentro do intervalo de datas e para o mesmo espaço
    existing_reservations = Reservation
                            .within_date_range(new_start_date, new_end_date)
                            .for_space(space_id)
                            .other_users(user_id)

    # Retorna os turnos que conflitam
    conflicting_shifts(existing_reservations, new_shifts)
  end

  # method to render the date in simple calendar
  def start_time
    self.start_date
  end

  def end_time
    self.end_date
  end
  

  private 
    def validate_unique_shifts
      overlapping_reservations = Reservation.where(
      space_id: space_id
    ).where("start_date <= ? AND end_date >= ?", end_date, start_date)
     .where("shifts && ARRAY[?]::varchar[]", shifts)

      if overlapping_reservations.exists?
        errors.add(:shifts, :taken, count: shifts.size)
      end
    end
end
