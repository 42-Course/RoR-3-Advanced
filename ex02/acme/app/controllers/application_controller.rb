class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Never show a Rails error page for a missing record — redirect with a notice.
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path, alert: "The page you were looking for doesn't exist."
  end

  protected

  # Let users set name/bio on sign-up and edit every field afterwards.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :bio])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :bio])
  end
end
