require 'rails_helper'

RSpec.describe ConfirmSubmission do
  describe '.for' do
    let(:submissions) { Array.new(5).map { double() } }

    subject(:services) { described_class.for(submissions) }

    it 'maps an array of submissions with this service' do
      expect(services).to all be_a(described_class)
    end
  end

  describe '#call' do
    let(:service) { described_class.new(submission) }

    let(:submission) do
      double(confirmed!: true, event: double(host: double()), profile: double())
    end

    subject(:call) { service.call }

    before do
      allow(Action).to receive(:create)
    end

    before do
      allow(submission.event).to receive(:full?).and_return(false)

      call
    end

    it 'returns the submission' do
      is_expected.to eq(submission)
    end

    it 'confirms the submission' do
      expect(submission).to have_received(:confirmed!).with(no_args)
    end

    it 'creates an event action' do
      expect(Action).to have_received(:create).with(notify: :later,
        actor: submission.profile, resource: submission.event, type: :join
      )
    end
  end
end
