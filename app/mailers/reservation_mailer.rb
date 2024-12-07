class ReservationMailer < ApplicationMailer
  def notify_admin_new_reservation(admin)
    @admin = admin

    mail to: @admin.email, subject: 'Nova reserva solicitada'
  end

  def notify_admin_destroy_reservation(admin)
    @admin = admin

    mail to: @admin.email, subject: 'Reserva excluída no sistema'
  end

  def notify_user_reservation(user)
    @user = user

    mail to: @user.email, subject: 'Informação da reserva'
  end

  def notify_user_destroy_reservation(user)
    @user = user

    mail to: @user.email, subject: 'Reserva excluída no sistema'
  end

  def notify_user_approve_reservation(user, justification)
    @user = user
    @justification = justification

    mail to: @user.email, subject: 'Informação sobre a reserva'
  end

  def notify_user_cancel_reservation(user, justification)
    @user = user
    @justification = justification

    mail to: @user.email, subject: 'Informação sobre a reserva'
  end

  def notify_user_update_reservation(user)
    @user = user

    mail to: @user.email, subject: 'Informação sobre a reserva'
  end
end
