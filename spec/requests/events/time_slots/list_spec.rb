require 'rails_helper'

RSpec.describe 'List event time slots', :type => :request do
  let(:event) { FactoryGirl.create(:event, :flexible) }

  let(:params) {}

  before do
    get event_time_slots_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action with pagination', :event, :time_slots

  it_behaves_like 'an action with sorting', :event, :time_slots, accept: %w(created_at begin_at)

  context "when event doesn't exist" do
    let(:event) { { event_id: 0 } }

    it { is_expected.to return_not_found }
  end

  context 'when user is authenticated as a member of an event time slot' do
    let(:event) { FactoryGirl.create(:event_with_time_slot_members) }

    let(:time_slot) { event.time_slots.shuffle.first }

    let(:authenticate) { time_slot.members.shuffle.first.user }

    it 'serializes the membership property of the appropriate time slot' do
      expect(json_attributes_for(time_slot)[:member]).to be_truthy
    end
  end
end
