class NotifyApproveReservationUserJob < ApplicationJob
  queue_as :default

  def perform(user)
    ReservationMailer.notify_user_approve_reservation(user).deliver_later
  end
end
