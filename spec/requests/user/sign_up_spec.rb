require 'rails_helper'

RSpec.describe 'User sign up', :type => :request do
  let(:params) { Serialize.params(sign_up_params, type: :users) }

  let(:sign_up_params) { user.attributes.merge(password: user.password) }

  before do
    post user_path, params: params, headers: json_headers
  end

  include_examples 'check parameters for', :users

  context 'when attributes are valid' do
    let(:user)         { FactoryGirl.build(:user) }
    let(:created_user) { User.find_by(email: user.email) }

    it { is_expected.to return_status_code 201 }

    it 'creates a new user with permited parameters' do
      permited_params = user.slice(
        :first_name, :last_name, :birthday, :phone_number, :culture
      )
      expect(created_user).to have_attributes(permited_params)
    end

    it 'creates the user with specified password' do
      expect(created_user.valid_password?(user.password)).to be_truthy
    end

    it 'returns the user attributes' do
      expect(response.body).to equal_serialized(created_user)
    end

    it 'grants the user with an achievement' do
      expect(created_user).to have_achievement('early-registration')
    end

    it { is_expected.to have_enqueued_welcome_email_for(created_user) }
  end

  context 'when attributes are invalid' do
    let(:user) { FactoryGirl.build(:user, email: 'test@') }

    it { is_expected.to return_validation_errors :user }
  end
end
