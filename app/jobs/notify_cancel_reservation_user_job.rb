class NotifyCancelReservationUserJob < ApplicationJob
  queue_as :default

  def perform(user)
    ReservationMailer.notify_user_cancel_reservation(user).deliver_later
  end
end
