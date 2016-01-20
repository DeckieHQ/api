require 'rails_helper'

RSpec.describe 'Users reset password instructions', :type => :request do
  before do
    post users_reset_password_instructions_path, { user: user.slice(:email) }, json_headers
  end

  context 'when user exists' do
    let(:user) { FactoryGirl.create(:user) }

    context 'with valid parameters' do
      before do
        user.reload
      end

      it { is_expected.to return_status_code 204 }

      xit 'creates a reset password token for the user' do
       expect(user.reset_password_token).to be_present
      end

      xit 'sends an email with reset password instructions' do
      end
    end

    context 'with invalid parameters' do

    end
  end

  context "when user doesn't exist" do
    let(:user) { FactoryGirl.build(:user) }


  end
end
