require 'rails_helper'

RSpec.describe 'Users reset password', :type => :request do
  before do
    put users_reset_password_path,
      params: { user: reset_password_params }, headers: json_headers
  end

  context 'when user exists' do
    let(:user) { FactoryGirl.create(:user) }

    context 'with a valid reset password token' do
      let(:reset_password_token) { user.send(:set_reset_password_token) }

      NEW_PASSWORD = 'azerty1234'

      context 'with valid password and password_confirmation' do
        let(:reset_password_params) do
          {
            reset_password_token: reset_password_token,
            password: NEW_PASSWORD,
            password_confirmation: NEW_PASSWORD
          }
        end

        before do
          user.reload
        end

        it { is_expected.to return_no_content }

        it 'updates the user password' do
          expect(user.valid_password?(NEW_PASSWORD)).to be_truthy
        end
      end

      context 'with invalid password confirmation' do
        let(:reset_password_params) do
          { reset_password_token: reset_password_token,
            password: NEW_PASSWORD,
            password_confirmation: "#{NEW_PASSWORD}."
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
    let(:user)                  { FactoryGirl.build(:user) }
    let(:reset_password_params) { Hash.new }

    it { is_expected.to return_not_found }
  end
end
