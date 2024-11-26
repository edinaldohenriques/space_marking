# Preview all emails at http://localhost:3000/rails/mailers/reservation_mailer
class ReservationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/reservation_mailer/notify_admin_new_reservation
  def notify_admin_new_reservation
    ReservationMailer.notify_admin_new_reservation
  end

end
