class CommentsScope
  def initialize(user, event)
    @user  = user
    @event = event
  end

  def default
    member? ? event.comments : event.public_comments
  end

  def filters
    member? ? { scopes: [:privates] } : {}
  end

  private

  attr_reader :user, :event

  def member?
    user && event.member?(user.profile)
  end
end
