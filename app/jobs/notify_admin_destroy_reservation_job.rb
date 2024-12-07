class NotifyAdminDestroyReservationJob < ApplicationJob
  queue_as :default

  def perform(admin)
    ReservationMailer.notify_admin_destroy_reservation(admin).deliver_later
  end
end
