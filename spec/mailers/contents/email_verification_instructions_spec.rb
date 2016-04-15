require 'rails_helper'

RSpec.describe EmailVerificationInstructions do
  let(:user) { FactoryGirl.create(:user).tap(&:generate_email_verification_token!) }

  subject(:content) { described_class.new(user) }

  describe '#username' do
    subject(:username) { content.username }

    it { is_expected.to eq(user.email) }
  end

  describe '#email_verification_url' do

    subject(:email_verification_url) { content.email_verification_url }

    it do
      is_expected.to equal_front_url_with(
        "verify_email?token=#{user.email_verification_token}"
      )
    end
  end
end
