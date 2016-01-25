require 'rails_helper'

RSpec.describe 'Users account update', :type => :request do
  let(:user_update)           { FactoryGirl.build(:user_update) }
  let(:account_update_params) { user_update.attributes }

  before do
    put users_account_update_path,
      params: { user: account_update_params }, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)          { FactoryGirl.create(:user) }
    let(:authenticated) { true }

    before do
      user.reload
    end

    context 'when attributes are valid' do
      let(:account_update_params) do
        user_update.attributes.merge(current_password: user.password)
      end

      it { is_expected.to return_status_code 200 }

      it 'returns the user attributes' do
        expect(response.body).to equal_serialized(user)
      end

      it 'updates the user with permited params' do
        permited_params = account_update_params.slice(
          'email', 'password', 'first_name', 'last_name', 'birthday', 'phone_number'
        )
        expect(user).to have_attributes(permited_params)
      end
    end

    context 'when attributes are not valid' do
      let(:user_update) { FactoryGirl.build(:user_update_invalid) }

      it { is_expected.to return_status_code 422 }
      it { is_expected.to return_validation_errors :user_update }
    end
  end
end
