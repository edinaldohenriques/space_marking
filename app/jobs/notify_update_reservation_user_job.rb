class NotifyUpdateReservationUserJob < ApplicationJob
  queue_as :default

  def perform(user)
    ReservationMailer.notify_user_update_reservation(user).deliver_later
  end
end
