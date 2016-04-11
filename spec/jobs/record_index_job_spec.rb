require 'rails_helper'

RSpec.describe RecordIndexJob, type: :job do
  it 'uses the default queue' do
    expect(described_class.queue_name).to eq('default')
  end

  subject(:record) do
    described_class.perform_now(event.id, event.class.name, remove)
  end

  let(:event) { FactoryGirl.create(:event) }

  context 'with remove' do
    let(:remove) { true }

    before do
      # Ensures that this job retrieves deleted records.
      event.destroy

      allow_any_instance_of(Event).to receive(:remove_from_index!)
    end

    it 'returns the matching record' do
      is_expected.to eq(event)
    end

    it 'removes the record from the index' do
      expect(record).to have_received(:remove_from_index!).with(no_args)
    end
  end

  context 'without remove' do
    let(:remove) { false }

    before do
      event

      allow_any_instance_of(Event).to receive(:index!)
    end

    it 'returns the matching record' do
      is_expected.to eq(event)
    end

    it 'indexes the record' do
      expect(record).to have_received(:index!).with(no_args)
    end
  end
end
