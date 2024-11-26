class NotifyAdminJob < ApplicationJob
  queue_as :default

  def perform(admin)
    ReservationMailer.notify_admin_new_reservation(admin).deliver_later
  end
end
