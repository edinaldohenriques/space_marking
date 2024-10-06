class Space < ApplicationRecord
  has_many :reservations, dependent: :destroy 

  validates :name, presence: true 
  validates :description, presence: true 
  validates :location, presence: true 
  validates :capacity, presence: true, numericality: { only_integer: true }

  # Filtro de shifts por associação com reservas
  scope :by_shifts, ->(shift) { joins(:reservations).merge(Reservation.by_shifts(shift)) if shift.present? }

  def self.available_spaces(selected_shifts)
    return all if selected_shifts.blank?

    Space
      .left_outer_joins(:reservations)
      .group('spaces.id')
      .having('COUNT(CASE WHEN reservations.shifts && ARRAY[?]::varchar[] THEN 1 END) = 0', selected_shifts)
  end

  # Atributos que podem ser pesquisados
  def self.ransackable_attributes(auth_object = nil)
    ["available", "board", "capacity", "created_at", "description", "id", "id_value", "laboratory", "location", "name", "projector", "updated_at"]
  end

  # Permitir busca através da associação 'reservations'
  def self.ransackable_associations(auth_object = nil)
    ["reservations"]
  end


end
