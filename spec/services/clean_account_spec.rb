require 'rails_helper'

RSpec.describe CleanAccount do
  let(:account) do
    instance_double('User',
      opened_hosted_events: Array.new(5),
      opened_submissions:   Array.new(5)
    )
  end

  let(:cancel_resource_services) do
    Array.new(5).map { double(call: true) }
  end

  let(:service) { CleanAccount.new(account) }

  describe '#call' do
    let!(:cancel_resource) do
      object_double('CancelResourceWithAction', for: cancel_resource_services).as_stubbed_const
    end

    before do
      service.call
    end

    it 'creates an array of cancel resource services' do
      expect(cancel_resource).to have_received(:for).with(
        [].concat(account.opened_hosted_events).concat(account.opened_submissions)
      )
    end

    it 'call the method #call on every cancel resource services' do
      cancel_resource_services.each do |cancel_resource_service|
        expect(cancel_resource_service).to have_received(:call).with(no_args)
      end
    end
  end
end
