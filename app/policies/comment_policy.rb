class CommentPolicy < ApplicationPolicy
  alias_method :comment, :record

  def index?
    !comment.private? || member?
  end

  def create?
    !comment.of_comment? && (!comment.private? || member?)
  end

  def update?
    comment_owner?
  end

  def destroy?
    comment_owner? || comment.resource.host == user.profile
  end

  def permited_attributes_for_create
    [:message, :private]
  end

  def permited_attributes_for_update
    [:message]
  end

  private

  def member?
    comment.resource.member?(user.profile)
  end

  def comment_owner?
    user.profile == comment.author
  end
end
