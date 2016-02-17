require 'rails_helper'

RSpec.describe Sort, :type => :model do
  describe '#params' do
    subject(:sort) { Sort.new(attributes, accept: []) }

    {
      'id':               [{ id: :asc }],
      '-count':           [{ count: :desc }],
      'begin_at,-end_at': [{ begin_at: :asc }, { end_at: :desc }],
      'a,,-':             [{ a: :asc }, { '': :asc }, { '-': :desc }]
    }.each do |combination, expected|
      context "with attributes = '#{combination}'" do
        let(:attributes) { combination }

        it "returns #{expected}" do
          expect(sort.params).to eq(expected)
        end
      end
    end

    context 'when attributes is null' do
      let(:attributes) {}

      it 'returns an empty array' do
        expect(sort.params).to eq([])
      end
    end
  end

  describe '#valid?' do
    subject(:sort) { Sort.new(attributes, accept: accept) }

    let(:accept) { [:begin_at, :end_at] }

    let(:errors) { sort.tap(&:valid?).errors }

    context 'when attributes are supported' do
      let(:attributes) { 'begin_at,-end_at' }

      it { is_expected.to be_valid }

      it 'has no error' do
        expect(errors).to be_empty
      end
    end

    context 'when atttributes is null' do
      let(:attributes) {}

      it { is_expected.to be_valid }
    end

    context 'when attributes are not supported' do
      let(:attributes) { 'plop,-end_at,test' }

      it { is_expected.to_not be_valid }

      it 'has an unsupported error' do
        expect_unsuported_error
      end
    end

    context 'when attributes is not a string' do
      let(:attributes) { { test: :test } }

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
