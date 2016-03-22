class CommentPolicy < ApplicationPolicy
  alias_method :comment, :record

  def permited_attributes
    [
      :message,
      :private
    ]
  end

  def create?
    !comment.private? || comment.resource.member?(user.profile)
  end

  def destroy?
    comment_owner?
  end

  private

  def comment_owner?
    user.profile == comment.author
  end
end
