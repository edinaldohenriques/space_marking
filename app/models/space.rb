class Space < ApplicationRecord
  has_many :reservations, dependent: :destroy 

  validates :name, presence: true 
  validates :location, presence: true 
  validates :capacity, presence: true

  # Atributos que podem ser pesquisados
  def self.ransackable_attributes(auth_object = nil)
    ["available", "board", "capacity", "created_at", "id", "id_value", "laboratory", "location", "name", "projector", "updated_at", "accessibility"]
  end

  # Permitir busca através da associação 'reservations'
  def self.ransackable_associations(auth_object = nil)
    ["reservations"]
  end


end
