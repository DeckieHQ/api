class CompleteVerification
  delegate :type, to: :verification

  def initialize(user, verification)
    @user         = user
    @verification = verification
  end

  def call
    user.tap(&:"verify_#{type}!")
  end

  private

  attr_reader :user, :verification
end
