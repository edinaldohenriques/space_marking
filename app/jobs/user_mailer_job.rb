class UserMailerJob < ApplicationJob
  queue_as :default

  def perform(user, notification, *args)
    Devise::Mailer.send(notification, user, *args).deliver_later
  end
end
