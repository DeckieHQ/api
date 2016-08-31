require 'rails_helper'

RSpec.describe 'User sign in', :type => :request do
  let(:params) { { user: user.slice(:email, :password) }.to_json }

  before do
    post sign_in_user_path, params: params, headers: json_headers
  end

  context 'when user exists' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to return_status_code 201 }

    it 'returns the user authentication token' do
      expect(json_response).to eq(
        { email: user.email, token: user.authentication_token }
      )
    end

    it 'sets the user :last_sign_in_at to current datetime' do
      expect(user.reload.last_sign_in_at).to equal_time(DateTime.current)
    end
  end

  context "when user doesn't exist" do
    let(:user) { FactoryGirl.build(:user) }

    it { is_expected.to return_status_code 401 }

    it 'returns an "invalid email or password" error' do
      expect(response.body).to eq(
        I18n.t('devise.failure.user.not_found_in_database')
      )
    end
  end

  context 'without parameters root' do
    let(:params) {}

    it { is_expected.to return_status_code 400 }
  end
end
