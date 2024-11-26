class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Tentativas automáticas em caso de falhas de rede ou deadlock
  retry_on Errno::ENETUNREACH, wait: :exponentially_longer, attempts: 5
  retry_on ActiveRecord::Deadlocked, wait: :exponentially_longer, attempts: 5

  # Captura de exceções e log de falhas
  rescue_from(StandardError) do |exception|
    Rails.logger.error("Job failed: #{exception.message}")
    # Adicionar lógica para notificação de falha (como e-mail)
  end
end
