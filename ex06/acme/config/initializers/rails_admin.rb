RailsAdmin.config do |config|
  config.asset_source = :sprockets

  # Inherit the app's controller so our rescue_from CanCan::AccessDenied turns
  # forbidden actions into a friendly redirect instead of a 500 error page.
  config.parent_controller = "::ApplicationController"

  ### Popular gems integration

  # == Devise ==
  # Any signed-in user may reach the panel (roles come in ex05).
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # == CanCanCan ==
  # Roles decide who can do what (see app/models/ability.rb).
  config.authorize_with :cancancan

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
