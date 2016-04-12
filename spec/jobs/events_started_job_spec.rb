require 'rails_helper'

RSpec.describe EventsStartedJob, type: :job do
  it 'uses the scheduler queue' do
    expect(described_class.queue_name).to eq('scheduler')
  end

  describe '#perform' do
    before do
      FactoryGirl.create_list(:event, 5)
      FactoryGirl.create_list(:event_closed, 5, :with_pending_submissions)

      allow(CancelSubmission).to receive(:for).and_call_original
    end


    it 'cancels all pending submissions of closed events' do
      Event.all.each do |event|
        expect(CancelSubmission).public_send(event.closed? ? :to : :not_to,
          receive(:for).with(event.pending_submissions, reason: :remove_start)
        )
      end

      described_class.perform_now

      Event.opened(false).each do |event|
        expect(event.pending_submissions).to be_empty
      end
    end
  end
end
