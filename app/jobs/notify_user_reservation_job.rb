class NotifyUserReservationJob < ApplicationJob
  queue_as :default

  def perform(user)
    ReservationMailer.notify_user_reservation(user).deliver_later
  end
end
