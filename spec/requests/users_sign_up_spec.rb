require 'rails_helper'

RSpec.describe 'POST /users', :type => :request do
  before do
    @sign_up_params = user.attributes.merge(password: user.password)

    post '/users', { user: @sign_up_params }, json_headers
  end

  context 'when attributes are valid' do
    let(:user)         { FactoryGirl.build(:user) }
    let(:created_user) { User.find_by(email: user.email) }

    it 'creates a new user with permited parameters' do
      permited_params = @sign_up_params.slice(
        'first_name', 'last_name', 'birthday'
      )
      expect(created_user).to have_attributes(permited_params)
    end

    it { is_expected.to return_status_code 201 }

    it 'returns the created user authentication token' do
      expect(json_response).to eq({ token: created_user.authentication_token })
    end
  end

  context 'when attributes are invalid' do
    let(:user) { FactoryGirl.build(:user, email: 'test@') }

    it { is_expected.to return_status_code 422 }

    it 'returns the validation errors' do
      user.valid?
      expect(json_response).to eq({ errors: user.errors.messages })
    end
  end
end
