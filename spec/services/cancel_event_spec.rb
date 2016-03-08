require 'rails_helper'

RSpec.describe CancelEvent do
  let(:service) { CancelEvent.new(event) }

  let(:event) { FactoryGirl.create(:event) }

  describe '#call' do
    subject(:call) { service.call }

    before { call }

    it { is_expected.to be_truthy }

    it 'destroys the event' do
      expect(event).to_not be_persisted
    end
  end
end
