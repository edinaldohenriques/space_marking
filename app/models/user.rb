class User < ApplicationRecord
  has_many :reservations, dependent: :destroy

  enum user_type: { "user": 0, "admin": 1 }

  validates :name, presence: true 
  validates :student_id_number, presence: true, length: { minimum: 7, maximum: 12 }
  validates :phone_number, phone: { possible: true, allow_blank: false }, on: :create
  validates :password, presence: true, on: :create 
  validates :password, confirmation: true, if: :password_required?
  validates :password_confirmation, presence: true, length: { maximum: 12 }, on: :create

  scope :admins, -> { where(user_type: user_types[:admin]) }

  # Include default devise modules. Others available are:
  # :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable, :timeoutable, :confirmable, :lockable

  def to_combobox_display
    name
  end

  def send_devise_notification(notification, *args)
    UserMailerJob.perform_later(self, notification, *args)
  end

  def formatted_phone_number
    phone = Phonelib.parse(phone_number)
    formatted = phone.local_number.presence || phone.full_national.presence
  end

  def password_required?
    new_record? 
  end
end
