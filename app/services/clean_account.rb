class CleanAccount
  def initialize(user)
    @user = user
  end

  def call
    user.opened_hosted_events.destroy_all
    user.opened_submissions.destroy_all
  end

  private

  attr_reader :user
end
