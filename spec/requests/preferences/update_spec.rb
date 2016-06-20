require 'rails_helper'

RSpec.describe 'User preferences update', :type => :request do
  let(:params) { Serialize.params(preferences_update_params, type: :preferences) }

  let(:preferences_update_params) { preferences_update.attributes }

  let(:preferences_update) { FactoryGirl.build(:preferences) }

  let(:preferences) { FactoryGirl.build(:preferences) }

  before do
    put preference_path(preferences.id), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    before { authenticate.reload }

    context 'with the preferences owner' do
      let(:authenticate) { preferences.user }

      include_examples 'check parameters for', :preferences

      context 'when attributes are valid' do
        it { is_expected.to return_status_code 200 }

        it 'returns the user preferences attributes' do
          expect(response.body).to equal_serialized(Preferences.for(authenticate))
        end

        it 'updates the user preferences with permited params' do
          expect(authenticate.preferences).to eq(preferences_update_params)
        end
      end

      context 'when attributes are not valid' do
        let(:preferences_update) { FactoryGirl.build(:preferences_invalid) }

        it { is_expected.to return_validation_errors :preferences_update }

        it "doesn't update the user preferences" do
          expect(authenticate.preferences).to_not eq(preferences_update_params)
        end
      end
    end

    context 'with another user' do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it "doesn't update the user preferences" do
        expect(authenticate.preferences).to_not eq(preferences_update_params)
      end
    end

    context "when preferences doesn't exist" do
      let(:authenticate) { FactoryGirl.create(:user) }

      let(:preferences) { Struct.new(:id).new(id: 0) }

      it { is_expected.to return_not_found }
    end
  end
end
