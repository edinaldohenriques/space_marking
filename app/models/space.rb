class Space < ApplicationRecord
  has_many :reservations, dependent: :destroy 

  validates :name, presence: true 
  validates :description, presence: true 
  validates :location, presence: true 
  validates :capacity, presence: true, numericality: { only_integer: true }

  scope :search, ->(query) {
    where("name ILIKE ? OR projector ILIKE ?", "%#{query}%", "%#{query}%") if query.present?
  }


   # Atributos que podem ser pesquisados pelo Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["available", "board", "capacity", "created_at", "description", "id", "id_value", "laboratory", "location", "name", "projector", "updated_at"]
  end

  # Atributos para pesquisa via associações (se necessário)
  def self.ransackable_associations(auth_object = nil)
    ["reservations"] # Exemplo de associação se precisar buscar por shifts nas reservas
  end


end
