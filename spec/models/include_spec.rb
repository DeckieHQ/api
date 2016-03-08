require 'rails_helper'

RSpec.describe Include, :type => :model do
  describe '#params' do
    subject(:include) { Include.new(attributes, accept: []) }

    context 'when attributes has a value' do
      let(:attributes) { 'comments,author,event.host' }

      it 'an array of attributes splitted by comma' do
        expect(include.params).to eq(attributes.split(','))
      end
    end

    context 'when attributes is null' do
      let(:attributes) {}

      it 'returns an empty array' do
        expect(include.params).to eq([])
      end
    end
  end

  describe '#valid?' do
    subject(:include) { Include.new(attributes, accept: accept) }

    let(:accept) { %w(comments comments.author events) }

    let(:errors) { include.tap(&:valid?).errors }

    context 'when attributes are supported' do
      let(:attributes) { 'comments.author,events' }

      it { is_expected.to be_valid }

      it 'has no error' do
        expect(errors).to be_empty
      end
    end

    context 'when attributes is null' do
      let(:attributes) {}

      it { is_expected.to be_valid }
    end

    context 'when attributes are not supported' do
      let(:attributes) { ['unknown'] }

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
      expect(errors).to be_added(:base, :unsupported, accept: accept)
    end
  end
end
