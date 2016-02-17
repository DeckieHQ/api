require 'rails_helper'

RSpec.describe 'User profile update', :type => :request do
  let(:params) { Serialize.params(profile_update_params, type: :profiles) }

  let(:profile_update_params) { profile_update.attributes }
  let(:profile_update)        { FactoryGirl.build(:profile) }

  before do
    put user_profile_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)         { FactoryGirl.create(:user) }
    let(:authenticate) { user }

    before do
      user.profile.reload
    end

    include_examples 'check parameters for', :profiles

    context 'when attributes are valid' do
      it { is_expected.to return_status_code 200 }

      it 'returns the user profile attributes' do
        expect(response.body).to equal_serialized(user.profile)
      end

      it 'updates the user profile with permited params' do
        permited_params = profile_update.slice(:nickname)

        expect(user.profile).to have_attributes(permited_params)
      end
    end

    context 'when attributes are not valid' do
      let(:profile_update) { FactoryGirl.build(:profile_invalid) }

      it { is_expected.to return_status_code 422 }
      it { is_expected.to return_validation_errors :profile_update }
    end
  end
end
