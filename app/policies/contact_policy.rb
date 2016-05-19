class ContactPolicy < ApplicationPolicy
  alias_method :contact, :record

  def show?
    user.host_of?(contact.user) || contact.user.host_of?(user)
  end
end
