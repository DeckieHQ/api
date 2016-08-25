require 'rails_helper'

RSpec.describe TimeSlotSubmissionPolicy do
  subject { described_class.new(user, time_slot_submission) }

  let(:time_slot_submission) { FactoryGirl.create(:time_slot_submission) }

  context 'being a visitor' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:show)    }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'being the time slot submission owner' do
    let(:user) { time_slot_submission.profile.user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:destroy) }
  end
end
