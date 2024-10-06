class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :space

  VALID_SHIFTS_ORDER = ["morning", "afternoon", "evening"].freeze

  validates :reservation_date, presence: true, reservation_date: { message: 'não pode ser anterior ao dia de hoje' }

  validate :validate_unique_shifts, on: :create
  # method to render the date in simple calendar
  def start_time
    self.reservation_date
  end


  # Filtro para encontrar reservas com base nos shifts (períodos)
  scope :by_shifts, ->(shift) { where("'#{shift}' = ANY (shifts)") if shift.present? }

  private 
    def validate_unique_shifts
      overlapping_reservations = Reservation.where(
        space_id: space_id,
        reservation_date: reservation_date
      ).where("shifts && ARRAY[?]::varchar[]", shifts)

      if overlapping_reservations.exists?
        errors.add(:shifts, :taken, count: shifts.size)
      end
    end
end
