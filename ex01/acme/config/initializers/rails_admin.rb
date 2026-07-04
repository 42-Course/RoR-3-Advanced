RailsAdmin.config do |config|
  config.asset_source = :sprockets

  ### Popular gems integration

  # == Devise ==
  # Uncomment once the User model / authentication exists (see later exercises).
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  # == CancanCan ==
  # config.authorize_with :cancancan

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
