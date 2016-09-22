require 'rails_helper'

RSpec.describe 'List user time slot submissions', :type => :request do
  let(:profile) { FactoryGirl.create(:profile, :with_time_slot_submissions) }

  before do
    get profile_time_slot_submissions_path(profile), params: params, headers: json_headers
  end

  it_behaves_like 'an action with pagination', :profile, :time_slot_submissions

  it_behaves_like 'an action with sorting', :profile, :time_slot_submissions,
    accept: ['created_at', 'time_slot.begin_at']

  it_behaves_like 'an action with include', :profile, :time_slot_submissions,
    accept: %w(time_slot time_slot.event)

  context "when profile doesn't exist" do
    let(:params) {}

    let(:profile) { { profile_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
