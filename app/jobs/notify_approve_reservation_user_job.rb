class NotifyApproveReservationUserJob < ApplicationJob
  queue_as :default

  def perform(user, justification)
    ReservationMailer.notify_user_approve_reservation(user, justification).deliver_later
  end
end
