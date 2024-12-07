class NotifyUserDestroyReservationJob < ApplicationJob
  queue_as :default

  def perform(user)
    ReservationMailer.notify_user_destroy_reservation(user).deliver_later
  end
end
