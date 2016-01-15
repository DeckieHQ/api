require 'rails_helper'

RSpec.describe 'POST /users', :type => :request do
  before do
    post '/users', { user: user.slice(:email, :password) }, json_headers
  end

  context 'when attributes are valid' do
    let(:user)         { FactoryGirl.build(:user) }
    let(:created_user) { User.find_by(email: user.email) }

    it 'creates a new user with the email/password' do
      expect(created_user).to be_present
    end

    it { is_expected.to return_status_code 201 }

    it 'returns the created user authentication token' do
      expect(json_response).to eq({ token: created_user.authentication_token })
    end
  end

  context 'when attributes are invalid' do
    let(:user) { FactoryGirl.build(:user, email: nil) }

    it { is_expected.to return_status_code 422 }

    it 'returns the validation errors' do
      user.save

      expect(json_response).to eq({ errors: user.errors.messages })
    end
  end
end
