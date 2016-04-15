require 'rails_helper'

RSpec.describe ResetPasswordInstructions do
  let(:user) { FactoryGirl.create(:user) }

  let(:reset_password_token) { user.send(:set_reset_password_token) }

  subject(:content) { described_class.new(user, reset_password_token) }

  describe '#username' do
    subject(:username) { content.username }

    it { is_expected.to eq(user.email) }
  end

  describe '#reset_password_url' do
    subject(:reset_password_url) { content.reset_password_url }

    it do
      is_expected.to equal_front_url_with("edit_password?token=#{reset_password_token}")
    end
  end
end
