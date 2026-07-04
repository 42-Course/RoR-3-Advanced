class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest — no privileges

    if user.has_role?(:administrator)
      # Administrators can do everything, everywhere.
      can :manage, :all
    elsif user.has_role?(:moderator)
      # Moderators may reach the admin panel but only manage the catalog.
      can :access, :rails_admin
      can :read, :dashboard
      can :manage, [Brand, Product]
    end
    # Regular users get nothing here — they can still shop (handled by
    # authenticate_user!), but have no admin/edit privileges until an
    # administrator grants them a role.
  end
end
