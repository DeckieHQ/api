RSpec.shared_examples 'an indexable resource' do |options = {}|
  factory_name = described_class.to_s.downcase

  subject(:model) { FactoryGirl.build(factory_name) }

  context 'after create commit' do
    before do
      use_fake_index_job

      model.save
    end

    it { expect_index_worker(with_remove: true) }
  end

  context 'after destroy commit' do
    before do
      model.save

      use_fake_index_job

      model.destroy
    end

    it { expect_index_worker(with_remove: true) }
  end

  context 'after touch' do
    before do
      model.save

      use_fake_index_job

      model.touch
    end

    it { expect_index_worker(with_remove: true) }
  end

  def use_fake_index_job
    allow(RecordIndexJob).to receive(:perform_later)
  end

  def expect_index_worker(with_remove:)
    expect(RecordIndexJob).to have_received(:perform_later)
      .with(model.class.name, model.id)
  end
end
