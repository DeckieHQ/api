require 'rails_helper'

RSpec.describe EventsStartedJob, type: :job do
  before do
    FactoryGirl.create_list(:event,        5)
    FactoryGirl.create_list(:event_closed, 5)

    allow(CancelSubmission).to receive(:for)

    described_class.perform_now
  end


  it 'cancels all pending submissions of closed events' do
    Event.all do |event|
      expect(CancelSubmission).public_send(event.closed? ? :to : :not_to,
        have_received(:for).with(event.pending_submissions, reason: :remove_start)
      )
    end
  end
end
