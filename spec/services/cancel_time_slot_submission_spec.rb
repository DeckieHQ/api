require 'rails_helper'

RSpec.describe CancelTimeSlotSubmission do
  describe '.for' do
    let(:time_slot_submissions) { Array.new(5).map { double() } }

    let(:services) { Array.new(5).map { double(call: true) } }

    before do
      allow(described_class).to receive(:new).and_return(*services)
    end

    it "gets an instance of #{described_class} for each given time slot submission" do
      described_class.for(time_slot_submissions)

      time_slot_submissions.each do |time_slot_submission|
        expect(described_class).to have_received(:new).with(time_slot_submission)
      end
    end
  end

  describe '#call' do
    subject(:service) { described_class.new(time_slot_submission) }

    let(:time_slot_submission) { FactoryGirl.create(:time_slot_submission) }

    before { service.call }

    it 'destroys the submission' do
      expect(TimeSlot.find_by(id: time_slot_submission.id)).to_not be_present
    end

    xit do
      is_expected.to have_created_action(time_slot_submission.profile, time_slot_submission.time_slot, :unsubmit)
    end
  end
end
