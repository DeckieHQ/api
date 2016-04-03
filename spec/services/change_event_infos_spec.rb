require 'rails_helper'

RSpec.describe ChangeEventInfos do
  describe '#call' do
    let(:actor) { FactoryGirl.create(:profile) }

    let(:event) { FactoryGirl.create(:event)   }

    subject(:call) { described_class.new(actor, event).call({}) }

    before do
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
    end
  end
end
