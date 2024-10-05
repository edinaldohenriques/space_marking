class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  private
    def user_not_authorized
      flash[:alert] = "Você não tem permissão para acessar esta página."
      redirect_to(request.referrer || root_path)
    end
  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :student_id_number])
    end
end
