class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :space

  enum status: { pending: 0, confirmed: 1, cancelled: 2 }

  validates :start_date, presence: true, start_date: { message: 'não pode ser anterior ao dia de hoje' }, on: :create
  validates :end_date, presence: true, end_date: { message: 'não pode ser menor a Data Inicial' }
  validates :shifts, presence: { message: 'O turno não pode ficar em branco' }
  validates :booking_information, presence: true
  validate :validate_unique_shifts, on: :create 

  # Escopos para consultas comuns
  scope :within_date_range, ->(start_date, end_date) { where("start_date <= ? AND end_date >= ?", end_date, start_date) if start_date.present? && end_date.present? }
  scope :for_space, ->(space_id) { where(space_id: space_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :other_users, ->(user_id) { where.not(user_id: user_id) }
  scope :with_shifts, ->(shifts) { where("shifts && ARRAY[?]::varchar[]", shifts) } # Verifica a interseção dos turnos
  scope :by_date_range, ->(start_date, end_date) {
  where("start_date <= ? AND end_date >= ? AND status = ?", end_date, start_date, Reservation.statuses[:confirmed]) if start_date.present? && end_date.present? } # para listar o histórico de reservas

  def self.translate_shifts(shifts)
    shifts.map { |shift| I18n.t("activerecord.attributes.reservation.shifts.#{shift}") }
  end

  def self.conflicting_shifts(existing_reservations, new_shifts)
    existing_reservations.map(&:shifts).flatten & new_shifts
  end

  # Método para adicionar turnos a uma reserva existente, garantindo que não haja duplicatas
  def self.add_shifts(existing_reservation, new_shifts)
    (existing_reservation.shifts + new_shifts).uniq
  end

  # método para renderizar data no simple calendar
  def start_time
    self.start_date
  end

  def end_time
    self.end_date
  end

  private 
    def validate_unique_shifts
      overlapping_reservations = Reservation.where(
      space_id: space_id)
      .where("start_date <= ? AND end_date >= ?", end_date, start_date)
      .where("shifts && ARRAY[?]::varchar[]", shifts)

      if overlapping_reservations.exists?
        errors.add(:shifts, "O turno(s) selecionado(s) já foi reservado para essa data")
      end
    end
end