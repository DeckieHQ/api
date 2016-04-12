RSpec.shared_examples 'an indexable resource' do |options = {}|
  factory_name = described_class.to_s.downcase

  subject(:model) { FactoryGirl.build(factory_name) }

  before do
    allow(RecordIndexJob).to receive(:perform_later)
  end

  context 'after create commit' do
    before { model.save }

    it 'calls algolia job with resource and without remove option' do
      expect_index_worker(with_remove: false)
    end
  end

  context 'after destroy commit' do
    before { model.tap(&:save).destroy }

    it 'calls algolia job with  resource and with remove option' do
      expect_index_worker(with_remove: true)
    end
  end

  def expect_index_worker(with_remove:)
    expect(RecordIndexJob).to have_received(:perform_later)
      .with(model.id, model.class.name, with_remove)
  end
end
