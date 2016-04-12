require 'rails_helper'

RSpec.describe JoinEvent do

  describe '#call' do
    let(:profile) { FactoryGirl.create(:profile) }

    let(:event)   { FactoryGirl.create(:event)   }

    subject(:call) { JoinEvent.new(profile, event).call }

    context 'when event has auto_accept' do
      before do
        allow(event).to receive(:auto_accept?).and_return(true)
      end

      it 'creates, confirms and return the new submission' do
        confirm_service = double(call: double())

        allow(ConfirmSubmission).to receive(:new) do |submission|
          expect(submission.attributes).to eql(
            Submission.new(profile: profile, event: event).attributes
          )
          confirm_service
        end
        is_expected.to eq(confirm_service.call)
      end
    end

    context "when event doesn't have auto_accept" do
      let(:new_submission) do
        Submission.find_by!(profile: profile, event: event, status: 'pending')
      end

      before do
        allow(event).to receive(:auto_accept?).and_return(false)
      end

      it 'creates and return the new pending submission' do
        is_expected.to eq(new_submission)
      end

      it { is_expected.to have_created_action(profile, event, :submit) }
    end
  end
end
