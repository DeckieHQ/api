require 'rails_helper'

RSpec.describe ReindexEventsJob, type: :job do
  it 'uses the scheduler queue' do
    expect(described_class.queue_name).to eq('scheduler')
  end

  describe '#perform' do
    before do
      allow(Event).to receive(:reindex!)

      described_class.perform_now
    end

    it 'reindexes the events' do
      expect(Event).to have_received(:reindex!)
    end
  end
end
