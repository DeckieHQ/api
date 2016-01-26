require 'rails_helper'

RSpec.describe 'Users sign in', :type => :request do
  before do
    post users_sign_in_path,
      params: { user: user.slice(:email, :password) }, headers: json_headers
  end

  context 'when user exists' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to return_status_code 201 }

    it 'returns the user authentication token' do
      expect(json_response).to eq({ token: user.authentication_token })
    end

    it 'sets the user :last_sign_in_at to current datetime' do
      user.reload
      expect(user.last_sign_in_at).to equal_time(DateTime.current)
    end
  end

  context "when user doesn't exist" do
    let(:user) { FactoryGirl.build(:user) }

    it { is_expected.to return_status_code 401 }

    it 'returns an "invalid email or password" error' do
      expected_response = { error: I18n.t(
        'devise.failure.invalid', { authentication_keys: 'email' }
      )}
      expect(json_response).to eq expected_response
    end
  end
end
