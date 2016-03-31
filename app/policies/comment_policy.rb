class CommentPolicy < ApplicationPolicy
  alias_method :comment, :record

  def create?
    !comment.private? || comment.resource.member?(user.profile)
  end

  def update?
    comment_owner?
  end

  def destroy?
    comment_owner?
  end

  def permited_attributes_for_create
    [:message, :private]
  end

  def permited_attributes_for_update
    [:message]
  end

  private

  def comment_owner?
    user.profile == comment.author
  end
end
