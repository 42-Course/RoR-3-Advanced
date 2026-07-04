class ApplicationController < ActionController::Base
  include CurrentCart

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Expose the session cart to every view (nav badge, etc.).
  helper_method :current_cart

  # Never show a Rails error page for a missing record — redirect with a notice.
  # (main_app.root_path so it also works when raised inside the RailsAdmin engine.)
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to main_app.root_path, alert: "The page you were looking for doesn't exist."
  end

  # A user who tries to reach something their role forbids is sent home, not
  # shown an error page (covers URL-tampering attempts).
  rescue_from CanCan::AccessDenied do
    redirect_to main_app.root_path, alert: "You are not authorized to do that."
  end

  protected

  # Let users set name/bio on sign-up and edit every field afterwards.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :bio])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :bio])
  end
end
