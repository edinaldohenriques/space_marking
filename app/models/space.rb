class Space < ApplicationRecord
  has_many :reservations, dependent: :destroy 

  enum floor: { ground: 0, first_floor: 1, second_floor: 2 }

  validates :name, presence: true 
  validates :location, presence: true 
  validates :capacity, presence: true

  # Atributos que podem ser pesquisados
  def self.ransackable_attributes(auth_object = nil)
    ["board", "capacity", "id", "id_value", "laboratory", "location", "name", "projector", "floor", "accessibility"]
  end

  # Permitir busca através da associação 'reservations'
  def self.ransackable_associations(auth_object = nil)
    ["reservations"]
  end
end
