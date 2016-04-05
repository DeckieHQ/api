RSpec.shared_examples 'acts as paranoid' do |options = {}|
  without_default_scope = options[:without_default_scope] || false

  factory_name = described_class.to_s.downcase

  subject(:model) { FactoryGirl.create(factory_name).destroy }

  context 'when destroyed' do
    before { model.destroy }

    it { is_expected.to be_persisted }

    it { is_expected.to be_deleted }
  end

  context '.default_scope' do
    let(:count) { 3 }

    before do
      FactoryGirl.create_list(factory_name, count).last.destroy
    end

    if without_default_scope
      it 'returns both undeleted and deleted records' do
        expect(described_class.count).to eq(count)
      end
    else
      it 'returns only undeleted records' do
        expect(described_class.count).to eq(count - 1)
      end
    end
  end
end
