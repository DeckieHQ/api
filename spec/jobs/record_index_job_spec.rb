require 'rails_helper'

RSpec.describe RecordIndexJob, type: :job do
  it 'uses the default queue' do
    expect(described_class.queue_name).to eq('default')
  end

  describe '#perform' do
    subject(:record) do
      described_class.perform_now(event.class.name, event.id)
    end

    let(:event) { FactoryGirl.create(:event) }

    context 'when not deleted' do
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

    context 'when deleted' do
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
  end
end
