require 'rails_helper'

RSpec.describe EventReady do
  let(:actor) { double() }

  describe '#call' do
    let(:event) { double(host: double(), destroy_pending_submissions: true) }

    let(:service) { described_class.new(event) }

    before do
      allow(Action).to receive(:create)
    end

    [:full, :start].each do |reason|
      context "with reason #{reason}" do
        subject(:call) { service.call(reason) }

        before { call }

        it 'destroy the event pending submissions' do
          expect(event).to have_received(:destroy_pending_submissions).with(no_args)
        end

        it 'creates an action' do
          expect(Action).to have_received(:create).with(
            actor: event.host, resource: event, type: reason, notify: :later
          )
        end
      end
    end
  end
end
