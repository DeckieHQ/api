RSpec.shared_examples 'acts as paranoid' do
  factory_name = described_class.to_s.downcase

  subject(:model) { FactoryGirl.create(factory_name).destroy }

  context 'when destroyed' do
    before { model.destroy }

    it { is_expected.to be_persisted }

    it { is_expected.to be_deleted }
  end
end
