require 'rails_helper'

RSpec.describe 'PATCH /users', :type => :request do
  let(:user)                  { FactoryGirl.create(:user) }
  let(:user_update)           { FactoryGirl.build(:user_update) }

  let(:account_update_params) { user_update.attributes }

  before do
    put '/users', { user: account_update_params }, json_headers

    user.reload
  end

  context 'when user is not authentified' do
    it { is_expected.to return_status_code 401 }

    it 'returns an unauthorized error' do
      expected_response = { error: I18n.t('failure.unauthorized') }

      expect(json_response).to eq expected_response
    end
  end

  context 'when user is authentified' do
    let(:authentified) { true }

    context 'when attributes are valid' do
      it { is_expected.to return_status_code 200 }

      it 'returns the user attributes' do
        expect(response.body).to equal_serialized(user)
      end

      it 'updates the user with permited params' do
        permited_params = account_update_params.slice(
          'email', 'first_name', 'last_name', 'birthday', 'phone_number'
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
