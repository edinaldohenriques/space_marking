class User < ApplicationRecord
  has_many :reservations, dependent: :destroy

  enum user_type: { 'user': 0, 'admin': 1 }

  validates :name, presence: true 

  # Include default devise modules. Others available are:
  # :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :confirmable, :lockable

end
