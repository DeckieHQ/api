require 'rails_helper'

RSpec.describe 'Users sign up', :type => :request do
  let(:sign_up_params) { user.attributes.merge(password: user.password) }

  before do
    params = {
      data: {
        type: 'users',
        attributes: sign_up_params
      }
    }
    post user_path, params: params, headers: json_headers
  end

  context 'when attributes are valid' do
    let(:user)         { FactoryGirl.build(:user) }
    let(:created_user) { User.find_by(email: user.email) }

    it { is_expected.to return_status_code 201 }

    it 'creates a new user with permited parameters' do
      permited_params = user.slice(:first_name, :last_name, :birthday)

      expect(created_user).to have_attributes(permited_params)
    end

    it 'returns the user attributes' do
      expect(response.body).to equal_serialized(created_user)
    end
  end

  context 'when attributes are invalid' do
    let(:user) { FactoryGirl.build(:user, email: 'test@') }

    it { is_expected.to return_status_code 422 }
    it { is_expected.to return_validation_errors :user }
  end

  context 'without parameters root' do
    let(:sign_up_params) {}

    it { is_expected.to return_bad_request }
  end
end
