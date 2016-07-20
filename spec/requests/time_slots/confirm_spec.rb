require 'rails_helper'

RSpec.describe 'Time slot delete', :type => :request do
  let(:time_slot) { FactoryGirl.create(:time_slot, :with_members) }

  let(:time_slot_members_ids) { time_slot.members.pluck('id') }

  let(:load_time_slot_members) { false }

  before do
    time_slot_members_ids if load_time_slot_members

    post confirm_time_slot_path(time_slot), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:event) { time_slot.event.reload }

    context 'when time slot event belongs to the user' do
      let(:authenticate) { time_slot.event.host.user }

      let(:load_time_slot_members) { true }

      it { is_expected.to return_status_code 200 }

      it 'returns the time slot event' do
        expect(response.body).to equal_serialized(event)
      end

      it 'confirms the time slot' do
        expect(event).to_not be_flexible
      end

      it 'creates an event submission for each time slot members' do
        expect(
          event.submissions.where(profile_id: time_slot_members_ids).count
        ).to eq(time_slot_members_ids.count)
      end

      it "destroys all the event time slots" do
        expect(event.time_slots).to be_empty
      end
    end

    context "when time slot doesn't exists" do
      let(:time_slot) { { id: 0 } }

      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_not_found }
    end

    context "when time slot event doesn't belong to the user" do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it "doesn't confirm the time slot" do
        expect(event).to be_flexible
      end
    end
  end
end
