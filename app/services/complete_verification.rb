class CompleteVerification
  def initialize(user, verification)
    @user         = user
    @verification = verification
  end

  def call
    user.tap(&:"verify_#{verification.type}!")
  end

  protected

  attr_reader :user, :verification
end
