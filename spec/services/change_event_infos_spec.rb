require 'rails_helper'

RSpec.describe ChangeEventInfos do
  let(:actor) { double() }

  let(:service) { described_class.new(actor, event) }

  describe '#call' do
    subject(:call) { service.call(params) }

    let(:params) { double() }

    context 'when resource update succeeded' do
      before do
        allow(Action).to receive(:create)

        allow(event).to receive(:update).and_return(event)
      end

      context 'when switched to auto accept' do
        let(:event) do
          double(switched_to_auto_accept?: true, max_confirmable_submissions: Array.new(5))
        end

        let(:confirm_resource_services) do
          event.max_confirmable_submissions.map { double(call: true) }
        end

        before do
          allow(ConfirmSubmission).to receive(:for).and_return(confirm_resource_services)

          call
        end

        it 'returns the event' do
          is_expected.to eq(event)
        end

        it 'creates an action' do
          expect(Action).to have_received(:create).with(
            actor: actor, resource: event, type: :update
          )
        end

        it 'maps each possible submissions with the confirmation service' do
          expect(ConfirmSubmission).to have_received(:for).with(
            event.max_confirmable_submissions
          )
        end

        it 'confirms each possible submissions' do
          confirm_resource_services.each do |confirm_resource_service|
            expect(confirm_resource_service).to have_received(:call).with(no_args)
          end
        end
      end

      context 'when not switched to auto accept' do
        let(:event) { double(switched_to_auto_accept?: false) }

        before { call }

        it 'returns the event' do
          is_expected.to eq(event)
        end

        it 'creates an action' do
          expect(Action).to have_received(:create).with(
            actor: actor, resource: event, type: :update
          )
        end
      end
    end

    context 'when resource update failed' do
      let(:event) { double(update: nil) }

      it 'returns the event' do
        is_expected.to eq(event)
      end
    end
  end
end
