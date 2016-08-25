require 'rails_helper'

RSpec.describe 'List time slot members', :type => :request do
  let(:time_slot) { FactoryGirl.create(:time_slot, :with_members) }

  let(:params) {}

  before do
    get time_slot_members_path(time_slot), params: params, headers: json_headers
  end

  it_behaves_like 'an action with pagination', :time_slot, :members

  it_behaves_like 'an action with sorting', :time_slot, :members, accept: %w(created_at)

  context "when time slot doesn't exist" do
    let(:time_slot) { { time_slot_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
