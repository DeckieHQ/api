require 'rails_helper'

RSpec.describe CancelTimeSlot do
  describe '#call' do
    let(:profile)   { FactoryGirl.create(:profile)   }

    let(:time_slot) { FactoryGirl.create(:time_slot) }

    subject(:service) { described_class.new(profile, time_slot) }

    subject(:call) { service.call }

    before { service.call }

    it { is_expected.to have_created_action(profile, time_slot, :cancel) }

    it 'destroys the resource' do
      expect(TimeSlot.find_by(id: time_slot.id)).to_not be_present
    end
  end
end
