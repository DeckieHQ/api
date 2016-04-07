require 'rails_helper'

RSpec.describe 'Reset user notifications count', :type => :request do
  before do
    post reset_notifications_count_user_path, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user, :with_notifications) }

    let(:authenticate) { user }

    before { user.reload }

    it { is_expected.to return_status_code 200 }

    it 'returns the user attributes' do
      expect(response.body).to equal_serialized(user)
    end

    it 'resets user notifications count' do
      expect(user.notifications_count).to eq(0)
    end
  end
end
