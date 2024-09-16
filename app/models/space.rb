class Space < ApplicationRecord
  has_many :reservations

  validates :name, presence: true 
  validates :description, presence: true 
  validates :board, presence: true 
  validates :laboratory, presence: true 
  validates :projector, presence: true 
  validates :location, presence: true 
  validates :capacity, presence: true, numericality: { only_integer: true }
end
