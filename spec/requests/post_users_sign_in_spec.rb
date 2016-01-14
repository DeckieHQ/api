require 'rails_helper'

RSpec.describe 'POST /users/sign_in', :type => :request do
  before do
    headers = { 'ACCEPT' => 'application/json' }

    post '/users/sign_in', { user: user.slice(:email, :password) }, headers
  end

  context 'when user exists' do
    let(:user) { FactoryGirl.create(:user) }

    it 'returns a 201 status code' do
      expect(response.code).to eq '201'
    end

    it 'returns the user authentication token' do
      expect(json_response).to eq({ token: user.authentication_token })
    end
  end

  context "when user doesn't exist" do
    let(:user) { FactoryGirl.build(:user) }

    it 'returns a 401 status code' do
      expect(response.code).to eq '401'
    end

    it 'returns an "invalid email or password" error' do
      expected_response = { error: I18n.t(
        'devise.failure.invalid', { authentication_keys: 'email' }
      )}
      expect(json_response).to eq expected_response
    end
  end
end
