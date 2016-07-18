require 'rails_helper'

RSpec.describe TimeSlotPolicy do
  subject { described_class.new(user, time_slot) }

  let(:time_slot) { FactoryGirl.create(:time_slot) }

  context 'being a visitor' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:destroy) }
  end

  context 'being the time slot event host' do
    let(:user) { time_slot.event.host.user }

    it { is_expected.to permit_action(:destroy) }
  end
end
