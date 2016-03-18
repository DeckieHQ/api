require 'rails_helper'

RSpec.describe 'User preferences infos', :type => :request do
  before do
    get user_preferences_path, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)         { FactoryGirl.create(:user) }
    let(:authenticate) { user }

    it { is_expected.to return_status_code 200 }

    it 'returns the user preferences attributes' do
      expect(response.body).to equal_serialized(
        Preferences.new(user.preferences)
      )
    end
  end
end
