require 'rails_helper'

RSpec.describe JoinTimeSlot do
  describe '#call' do
    let(:profile) { FactoryGirl.create(:profile) }

    let(:time_slot) { FactoryGirl.create(:time_slot)   }

    subject(:call) { described_class.new(time_slot, profile).call }

    before { call }

    it do
      is_expected.to have_created_action(profile, time_slot, :join)
    end

    it 'creates a time slot submission for the given profile' do
      expect(time_slot.members.find_by(id: profile.id)).to be_present
    end
  end
end
