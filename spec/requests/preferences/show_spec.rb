require 'rails_helper'

RSpec.describe 'Preferences show', :type => :request do
  let(:preferences) { FactoryGirl.build(:preferences) }

  before do
    get preference_path(preferences.id), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'with the preferences owner' do
      let(:authenticate) { preferences.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the user preferences attributes' do
        expect(response.body).to equal_serialized(Preferences.for(preferences.user))
      end
    end

    context 'with another user' do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }
    end

    context "when preferences doesn't exist" do
      let(:authenticate) { FactoryGirl.create(:user) }

      let(:preferences) { Struct.new(:id).new(id: 0) }

      it { is_expected.to return_not_found }
    end
  end
end
