class CommentPolicy < ApplicationPolicy
  include PolicyMatchers::Event
  
  alias_method :comment, :record

  def index?
    !comment.private? || member?
  end

  def create?
    !comment.of_comment? && (!comment.private? || member?) && !event_recurrent?
  end

  def update?
    user.moderator? || comment_owner?
  end

  def destroy?
    user.moderator? || comment_owner? || comment.resource.host == user.profile
  end

  def permited_attributes_for_create
    [:message, :private]
  end

  def permited_attributes_for_update
    [:message]
  end

  private

  def event
    comment.resource
  end

  def member?
    comment.resource.member?(user.profile)
  end

  def comment_owner?
    user.profile == comment.author
  end
end
