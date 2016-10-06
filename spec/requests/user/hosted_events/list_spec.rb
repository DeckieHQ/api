require 'rails_helper'

RSpec.describe 'User hosted event list', :type => :request do
  before do
    get user_hosted_events_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) do
      events_count = Faker::Number.between(4, 15)

      FactoryGirl.create(:user_with_hosted_events, events_count: events_count)
    end

    let(:authenticate) { user }

    it_behaves_like 'an action with pagination', :user, :hosted_events

    it_behaves_like 'an action with filtering', :user, :hosted_events,
      accept: { scopes: [:opened, :type] },
      try: { opened: [true, false, nil, 1, 0], type: [:normal, 0, 1, nil] }

    it_behaves_like 'an action with sorting', :user, :hosted_events,
      accept: %w(begin_at end_at)
  end
end
