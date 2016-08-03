require 'rails_helper'

RSpec.describe 'List event time_slot_members', :type => :request do
  let(:event) { FactoryGirl.create(:event_with_time_slots_members) }

  let(:params) {}

  before do
    get event_time_slots_members_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action with pagination', :event, :time_slots_members

  it_behaves_like 'an action with include', :event, :time_slots_members,
    accept: %w(time_slot_submissions)

  context "when event doesn't exist" do
    let(:event) { { event_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
