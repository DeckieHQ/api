require 'rails_helper'

RSpec.describe 'Users reset password instructions', :type => :request do
  let(:reset_password_params) { { user: user.slice(:email) } }

  before do
    post users_reset_password_path, params: reset_password_params, headers: json_headers
  end

  after do
    MailDeliveries.clear
  end

  context 'when user exists' do
    let(:user) { FactoryGirl.create(:user) }

    context 'with valid parameters' do

      before do
        user.reload
      end

      it { is_expected.to return_status_code 204 }

      it 'creates a reset password token for the user' do
        expect(user.reset_password_token).to be_present
      end

      it 'sends an email with reset password instructions' do
        expect(MailDeliveries.last).to equal_mail(
          UserMailer.reset_password_instructions(user, user.reset_password_token)
        )
      end
    end
  end

  context "when user doesn't exist" do
    let(:user) { FactoryGirl.build(:user) }

    it { is_expected.to return_not_found }

    it { is_expected.not_to have_sent_mail }
  end

  context 'without parameters root' do
    let(:reset_password_params) {}

    it { is_expected.to return_bad_request }
  end
end
