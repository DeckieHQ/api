require 'rails_helper'

RSpec.describe 'Users reset password', :type => :request do
  before do
    put users_reset_password_path,
      params: { user: reset_password_params }, headers: json_headers
  end

  context 'when user exists' do
    let(:user)     { FactoryGirl.create(:user) }
    let(:password) { Faker::Internet.password }

    context 'with a valid reset password token' do
      let(:reset_password_token) { user.send(:set_reset_password_token) }

      context 'with valid password and password_confirmation' do
        let(:reset_password_params) do
          {
            reset_password_token: reset_password_token,
            password: password,
            password_confirmation: password
          }
        end

        before do
          user.reload
        end

        it { is_expected.to return_no_content }

        it 'updates the user password' do
          expect(user.valid_password?(password)).to be_truthy
        end
      end

      context 'with invalid password confirmation' do
        let(:reset_password_params) do
          { reset_password_token: reset_password_token,
            password: password,
            password_confirmation: "#{password}."
          }
        end

        it { is_expected.to return_status_code 422 }

        it { is_expected.to return_validation_errors_on :password_confirmation }
      end

      context 'with invalid password' do
        let(:reset_password_params) do
          { reset_password_token: reset_password_token,
            password: '.',
            password_confirmation: '.'
          }
        end

        it { is_expected.to return_status_code 422 }

        it { is_expected.to return_validation_errors_on :password }
      end
    end

    context 'with invalid :reset_password_token' do
      let(:reset_password_params) { { reset_password_token: '.' } }

      it { is_expected.to return_status_code 422 }

      it { is_expected.to return_validation_errors_on :reset_password_token }
    end
  end

  context "when user doesn't exist" do
    let(:reset_password_params) do
      { reset_password_token: Faker::Hipster.sentence }
    end

    it { is_expected.to return_status_code 422 }

    it { is_expected.to return_validation_errors_on :reset_password_token }
  end

  context 'without parameters root' do
    let(:reset_password_params) {}

    it { is_expected.to return_bad_request }
  end
end
