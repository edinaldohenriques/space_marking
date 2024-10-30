class User < ApplicationRecord
  has_many :reservations, dependent: :destroy

  enum user_type: { "user": 0, "admin": 1 }

  validates :name, presence: true 
  validates :student_id_number, presence: true, length: { minimum: 7, maximum: 12 }
  #Ex:- :limit => 40

  # Include default devise modules. Others available are:
  # :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :confirmable, :lockable

  def to_combobox_display
    name
  end       

end
