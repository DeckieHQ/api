require 'rails_helper'

RSpec.describe 'Profile hosted event list', :type => :request do
  before do
    get profile_hosted_events_path(profile), params: params, headers: json_headers
  end

  let(:profile) do
    events_count = Faker::Number.between(4, 15)

    FactoryGirl.create(:user_with_hosted_events, events_count: events_count).profile
  end

  it_behaves_like 'an action with pagination', :profile, :hosted_events

  it_behaves_like 'an action with filtering', :profile, :hosted_events,
    accept: { scopes: [:opened, :type] },
    try: { opened: [true, false, nil, 1, 0], type: [:normal, 0, 1, nil] }

  it_behaves_like 'an action with sorting', :profile, :hosted_events,
    accept: %w(begin_at end_at)

  context "when profile doesn't exist" do
    let(:params) {}

    let(:profile) { { profile_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
