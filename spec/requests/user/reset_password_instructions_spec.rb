require 'rails_helper'

RSpec.describe 'User reset password instructions', :type => :request do
  let(:params) { Serialize.params(reset_password_params, type: :users) }

  let(:reset_password_params) { user.slice(:email) }

  before do
    post user_password_path, params: params, headers: json_headers
  end

  after do
    MailDeliveries.clear
  end

  include_examples 'check parameters for', :users

  context 'when user exists' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      user.reload
    end

    it { is_expected.to return_no_content }

    it 'creates a reset password token for the user' do
      expect(user.reset_password_token).to be_present
    end

    it 'sends an email with reset password instructions' do
      expect(MailDeliveries.last).to equal_mail(
        UserMailer.reset_password_instructions(user, user.reset_password_token)
      )
    end
  end

  context "when user doesn't exist" do
    let(:user) { FactoryGirl.build(:user) }

    it { is_expected.to return_not_found }

    it { is_expected.not_to have_sent_mail }
  end
end
