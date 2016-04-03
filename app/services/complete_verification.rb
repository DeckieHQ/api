class CompleteVerification
  def initialize(user, verification)
    @user         = user
    @verification = verification
  end

  def call
    user.tap(&:"verify_#{verification.type}!")
  end

  private

  attr_reader :user, :verification
end
