require 'rails_helper'

RSpec.describe ReindexEventsJob, type: :job do
  before do
    allow(Event).to receive(:reindex!)

    described_class.perform_now
  end

  it 'reindexes the events' do
    expect(Event).to have_received(:reindex!)
  end
end
