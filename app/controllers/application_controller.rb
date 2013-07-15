class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # CanCan unauthorized exception
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => exception.message
  end

  # redirect to dashboard after login
  def after_sign_in_path_for(user)
    dashboard_path
  end

  # redirect to root after logout
  def after_sign_out_path_for(user)
    root_path
  end
  
  # This is needed by devise to allow other parameters during user registration
  before_filter :configure_permitted_parameters, if: :devise_controller?
  protected
   def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) {
    	|u| u.permit(:first_name, :name, :surname, :team_id, :detailed, :password, :password_confirmation, :email)
    }
    devise_parameter_sanitizer.for(:account_update) {
    	|u| u.permit(:first_name, :name, :surname, :team_id, :detailed, :current_password, :password, :password_confirmation, :email)
    }
  end
end
