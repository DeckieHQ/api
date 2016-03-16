require 'rails_helper'

RSpec.describe 'User preferences update', :type => :request do
  let(:params) { Serialize.params(preferences_update_params, type: :preferences) }

  let(:preferences_update_params) { preferences_update.attributes }

  let(:preferences_update) { FactoryGirl.build(:preferences) }

  before do
    put user_preferences_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)         { FactoryGirl.create(:user) }
    let(:authenticate) { user }

    before { user.reload }

    include_examples 'check parameters for', :preferences

    context 'when attributes are valid' do
      it { is_expected.to return_status_code 200 }

      it 'returns the user preferences attributes' do
        expect(response.body).to equal_serialized(
          Preferences.new(user.preferences)
        )
      end

      it 'updates the user preferences with permited params' do
        expect(user.preferences).to eq(preferences_update_params)
      end
    end

    context 'when attributes are not valid' do
      let(:preferences_update) { FactoryGirl.build(:preferences_invalid) }

      it { is_expected.to return_status_code 422 }
      it { is_expected.to return_validation_errors :preferences_update }

      it "doesn't update the user preferences" do
        expect(user.reload.preferences).to_not eq(preferences_update_params)
      end
    end
  end
end
