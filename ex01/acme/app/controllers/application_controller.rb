class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Let users set name/bio on sign-up and edit every field afterwards.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :bio])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :bio])
  end
end
