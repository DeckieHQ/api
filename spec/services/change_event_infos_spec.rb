require 'rails_helper'

RSpec.describe ChangeEventInfos do
  describe '.of' do
    let(:profile) { double() }

    let(:events)   { Array.new(5).map { double() } }

    let(:params) { double() }

    let(:services) { Array.new(5).map { double(call: true) } }

    before do
      allow(described_class).to receive(:new).and_return(*services)

      described_class.of(profile, events, with: params)
    end

    it "gets an instance of #{described_class} for given profile and each given event" do
      events.each do |event|
        expect(described_class).to have_received(:new).with(profile, event)
      end
    end

    it "call on each services of #{described_class}" do
      services.each do |service|
        expect(service).to have_received(:call).with(params)
      end
    end
  end

  describe '#call' do
    let(:actor) { FactoryGirl.create(:profile) }

    let(:event) { FactoryGirl.create(:event)   }

    let(:params) { double() }

    subject(:call) { described_class.new(actor, event).call(params) }

    before do
      allow(described_class).to receive(:of)

      allow(ConfirmSubmission).to receive(:for)
    end

    context 'when resource update succeeded' do
      before do
        allow(event).to receive(:update).and_return(event)
      end

      context 'when switched to auto accept' do
        before do
          allow(event).to receive(:switched_to_auto_accept?).and_return(true)
        end

        it 'returns the event' do
          is_expected.to eq(event)
        end

        it { is_expected.to have_created_action(actor, event, :update) }

        it 'confirm every submission as possible' do
          call

          expect(ConfirmSubmission).to have_received(:for).with(
            event.max_confirmable_submissions
          )
        end
      end

      context 'when not switched to auto accept' do
        before do
          allow(event).to receive(:switched_to_auto_accept?).and_return(false)
        end

        it 'returns the event' do
          is_expected.to eq(event)
        end

        it { is_expected.to have_created_action(actor, event, :update) }

        it "doesnt't confirm any submission" do
          call

          expect(ConfirmSubmission).to_not have_received(:for)
        end
      end

      it "didn't cancel any children" do
        call

        expect(described_class).to have_received(:of).with(actor, [], with: params)
      end

      context 'when event has children' do
        let(:event) { FactoryGirl.create(:event, :recurrent) }

        it 'cancels the event children' do
          call

          expect(described_class).to have_received(:of).with(actor, event.children, with: params)
        end
      end
    end

    context 'when resource update failed' do
      before do
        allow(event).to receive(:update).and_return(nil)
      end

      it 'returns the event' do
        is_expected.to eq(event)
      end

      it "doesnt't confirm any submission" do
        call

        expect(ConfirmSubmission).to_not have_received(:for)
      end

      it "didn't cancel any children" do
        call

        expect(described_class).to_not have_received(:of)
      end
    end
  end
end
