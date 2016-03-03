class VerificationPolicy < ApplicationPolicy
  alias_method :verification, :record

  def create?
    !user_attribute_unspecified? && !user_attribute_verified?
  end

  def update?
    create?
  end

  private

  def user_attribute_verified?
    if user.send(:"#{attribute_name}_verified?")
      add_error(:"#{attribute_name}_already_verified")
    end
  end

  def user_attribute_unspecified?
    unless user_attribute.present?
      add_error(:"#{attribute_name}_unspecified")
    end
  end

  def user_attribute
    user.send(attribute_name)
  end

  def attribute_name
    verification.type
  end
end
