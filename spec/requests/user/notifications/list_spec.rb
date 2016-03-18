require 'rails_helper'

RSpec.describe 'List user notifications', :type => :request do
  let(:params) {}

  before do
    get user_notifications_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user, :with_notifications) }

    let(:authenticate) { user }

    it 'returns metadata with remaining notifications count'do
      expect(json_response[:meta]).to eq({
        remainings_count: user.notifications.remainings_count
      })
    end

    it_behaves_like 'an action with pagination', :user, :notifications

    it_behaves_like 'an action with sorting', :user, :notifications,
      accept: ['created_at']

    it_behaves_like 'an action with include', :user, :notifications,
       accept: %w(action action.actor)
  end
end
