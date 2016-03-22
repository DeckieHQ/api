require 'rails_helper'

RSpec.describe CleanAccount do
  let(:account) do
    instance_double('User',
      opened_hosted_events: Array.new(5),
      opened_submissions:   Array.new(5)
    )
  end

  let(:service) { CleanAccount.new(account) }

  describe '#call' do
    let(:cancel_event_services) do
      Array.new(5).map { double(call: true) }
    end

    let(:cancel_submission_services) do
      Array.new(3).map { double(call: true) }
    end

    before do
      allow(CancelEvent).to      receive(:for).and_return(cancel_event_services)
      allow(CancelSubmission).to receive(:for).and_return(cancel_submission_services)

      service.call
    end

    it 'maps each account opened_hosted_events with a cancel event service' do
      expect(CancelEvent).to have_received(:for).with(account, account.opened_hosted_events)
    end

    it 'call the method #call on every cancel event services' do
      cancel_event_services.each do |cancel_event_service|
        expect(cancel_event_service).to have_received(:call).with(no_args)
      end
    end

    it 'maps each account opened_submissions with a cancel submission service' do
      expect(CancelSubmission).to have_received(:for).with(account.opened_submissions)
    end

    it 'call the method #call on every cancel submission services' do
      cancel_submission_services.each do |cancel_submission_service|
        expect(cancel_submission_service).to have_received(:call).with(no_args)
      end
    end
  end
end
