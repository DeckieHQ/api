require 'rails_helper'

RSpec.describe 'Time slot delete', :type => :request do
  let(:time_slot) { FactoryGirl.create(:time_slot) }

  before do
    delete time_slot_path(time_slot), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'when time slot event belongs to the user' do
      let(:authenticate) { time_slot.event.host.user }

      it { is_expected.to return_status_code 204 }

      it 'deletes the time slot' do
        expect(TimeSlot.find_by(id: time_slot.id)).to be_nil
      end

      it do
        is_expected.to have_created_action(authenticate.profile, time_slot, :cancel)
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

      it "doesn't destroy the time slot" do
        expect(time_slot.reload).to be_persisted
      end

      it do
        is_expected.to_not have_created_action(authenticate.profile, time_slot, :cancel)
      end
    end
  end
end
