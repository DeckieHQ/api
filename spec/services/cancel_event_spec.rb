require 'rails_helper'

RSpec.describe CancelEvent do
  describe '.for' do
    let(:profile) { double() }

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
    let(:profile) { FactoryGirl.create(:profile) }

    let(:event) { FactoryGirl.create(:event) }

    subject(:service) { described_class.new(profile, event) }

    subject(:call) { service.call }

    before { service.call }

    it { is_expected.to have_created_action(profile, event, :cancel) }

    it 'destroys the resource' do
      expect(event).to be_deleted
    end
  end
end
