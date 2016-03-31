require 'rails_helper'

RSpec.describe CancelEvent do
  let(:actor) { double() }

  describe '.for' do
    let(:events) { Array.new(5).map { double() } }

    subject(:services) { described_class.for(actor, events) }

    it 'maps an array of events with this service' do
      expect(services).to all be_a(described_class)
    end
  end

  describe '#call' do
    let(:event) { double(destroy: true) }

    let(:service) { described_class.new(actor, event) }

    subject(:call) { service.call }

    before do
      allow(Action).to receive(:create)

      call
    end

    it 'creates an action' do
      expect(Action).to have_received(:create).with(
        actor: actor, resource: event, type: :cancel, notify: :later
      )
    end

    it 'destroy the resource' do
      expect(event).to have_received(:destroy).with(no_args)
    end
  end
end
