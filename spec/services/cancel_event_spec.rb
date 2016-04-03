require 'rails_helper'

RSpec.describe CancelEvent do
  let(:profile) { double() }

  describe '.for' do
    let(:events)   { Array.new(5).map { double() } }

    let(:services) { Array.new(5).map { double(call: true) } }

    before do
      allow(described_class).to receive(:new).and_return(*services)

      described_class.for(profile, events)
    end

    it "gets an instance of #{described_class} for given profile and each given event" do
      events.each do |event|
        expect(described_class).to have_received(:new).with(profile, event)
      end
    end

    it "call on each services of #{described_class}" do
      services.each do |service|
        expect(service).to have_received(:call).with(no_args)
      end
    end
  end

  describe '#call' do
    let(:event) { double(destroy: true) }

    let(:service) { described_class.new(profile, event) }

    subject(:call) { service.call }

    before do
      allow(Action).to receive(:create)

      call
    end

    it 'creates an action' do
      expect(Action).to have_received(:create).with(
        actor: profile, resource: event, type: :cancel, notify: :later
      )
    end

    it 'destroy the resource' do
      expect(event).to have_received(:destroy).with(no_args)
    end
  end
end
