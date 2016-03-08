require 'rails_helper'

RSpec.describe Filters, :type => :model do
  describe '#params' do
    subject(:filters) { Filters.new(attributes, accept: {}) }

    context 'when attributes has a value' do
      let(:attributes) { { test: :params } }

      it 'returns the attributes' do
        expect(filters.params).to eq(attributes)
      end
    end

    context 'when attributes is null' do
      let(:attributes) {}

      it 'returns an empty hash' do
        expect(filters.params).to eq({})
      end
    end
  end

  describe '#valid?' do
    subject(:filters) { Filters.new(attributes, accept: accept) }

    let(:accept) do
      {
        scopes: [:status, :published], associations_scopes: { event: [:opened] }
      }
    end

    let(:errors) { filters.tap(&:valid?).errors }

    context 'when attributes are supported' do
      let(:attributes) { { status: :ended, published: true } }

      it { is_expected.to be_valid }

      it 'has no error' do
        expect(errors).to be_empty
      end
    end

    context 'when attributes is null' do
      let(:attributes) {}

      it { is_expected.to be_valid }
    end

    context 'with nested attributes' do
      [
        { event: { opened: true } },
        { event: :opened }
      ].each do |combination|
        context "with #{combination}" do
          let(:attributes) { combination }

          it { is_expected.to be_valid }
        end
      end
    end

    context 'when attributes are not supported' do
      let(:attributes) { { huh: :nope, rofl: :maoh } }

      it { is_expected.to_not be_valid }

      it 'has an unsupported error' do
        expect_unsuported_error
      end

      context 'with nested attributes' do
        let(:attributes) { { event: { test: :wtf } } }

        it { is_expected.to_not be_valid }

        it 'has an unsupported error' do
          expect_unsuported_error
        end
      end
    end

    context 'when attributes is not a hash' do
      let(:attributes) { '?' }

      it { is_expected.to_not be_valid }

      it 'has an unsupported error' do
        expect_unsuported_error
      end
    end

    def expect_unsuported_error
      added = errors.added?(:base, :unsupported, accept: accept)

      expect(added).to be_truthy
    end
  end
end
