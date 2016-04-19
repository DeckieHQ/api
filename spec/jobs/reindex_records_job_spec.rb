require 'rails_helper'

RSpec.describe ReindexRecordsJob, type: :job do
  describe '#perform' do
    ['Event'].each do |record_type|
      context "with record type #{record_type}" do
        klass = record_type.constantize

        context 'with empty ids' do
          before do
            allow(klass).to receive(:reindex!)

            described_class.perform_now(record_type, [])
          end

          it "reindexes all #{record_type.pluralize}" do
            expect(klass).to have_received(:reindex!)
          end

          it 'uses the scheduler queue' do
            expect(
              described_class.new(record_type, []).queue_name
            ).to eq('scheduler')
          end
        end

        context 'when ids are not specified' do
          before do
            allow(klass).to receive(:reindex!)

            described_class.perform_now(record_type)
          end

          it "reindexes all #{record_type.pluralize}" do
            expect(klass).to have_received(:reindex!)
          end
        end

        context 'with ids' do
          let(:ids) { [1, 2, 3] }

          let(:records) { double(reindex!: nil) }

          before do
            allow(klass).to receive(:where).and_raise('Ids not received.')

            allow(klass).to receive(:where).with(id: ids).and_return(records)

            described_class.perform_now(record_type, ids)
          end

          it "reindexes only specified #{record_type.pluralize}" do
            expect(records).to have_received(:reindex!)
          end

          it 'uses the indexation queue' do
            expect(
              described_class.new(record_type, ids).queue_name
            ).to eq('indexation')
          end
        end
      end
    end
  end
end
