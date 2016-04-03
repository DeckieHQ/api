require 'rails_helper'

RSpec.describe EventReady do
  describe '#call' do
    let(:event) { FactoryGirl.create(:event) }

    subject(:service) { described_class.new(event) }

    before do
      allow(event).to receive(:destroy_pending_submissions)
    end

    [:full].each do |reason|
      context "with reason :#{reason}" do

        before { service.call(reason) }

        it 'destroy the event pending submissions' do
          expect(event).to have_received(:destroy_pending_submissions).with(no_args)
        end

        it { is_expected.to have_created_action(event.host, event, reason) }
      end
    end
  end
end
