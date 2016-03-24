class SendVerification
  Result ||= ImmutableStruct.new(:instructions_sent?, :error)

  delegate :type, to: :verification

  def initialize(user, verification)
    @user         = user
    @verification = verification
  end

  def call
    user.send("generate_#{type}_verification_token!")

    unless user.send("send_#{type}_verification_instructions")
      return Result.new(instructions_sent: false, error: :"#{type}_unassigned")
    end
    return Result.new(instructions_sent: true)
  end

  private

  attr_reader :user, :verification
end
