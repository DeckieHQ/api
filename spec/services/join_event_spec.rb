require 'rails_helper'

RSpec.describe JoinEvent do
  describe '.for' do
    let(:profile) { double() }

    let(:profiles)   { Array.new(5).map { double() } }

    let(:event) { double() }

    let(:services) { Array.new(5).map { double(call: true) } }

    before do
      allow(described_class).to receive(:new).and_return(*services)

      described_class.for(event, profiles)
    end

    it "gets an instance of #{described_class} for given event and each given profile" do
      profiles.each do |profile|
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
