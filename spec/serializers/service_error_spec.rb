require 'rails_helper'

RSpec.describe ServiceErrorSerializer, :type => :serializer do
  Result = ImmutableStruct.new(:error)

  describe '#serialize' do
    let(:result) { Result.new(error: Faker::Lorem.word) }

    let(:serialized) do
      ServiceErrorSerializer.new(result).serialize
    end

    it 'returns an array with only one error' do
      expect(serialized[:errors].length).to eq(1)
    end

    describe 'this error' do
      let(:error) { serialized[:errors].first }

      it 'has a 422 status' do
        expect(error[:status]).to eq(422)
      end

      it 'has the code equal to the error code' do
        expect(error[:code]).to eq(result.error)
      end

      it 'has the corresponding error detail' do
        expect(error[:detail]).to eq(
          I18n.t("service.errors.#{error[:code]}")
        )
      end

      it 'has an empty string as source pointer' do
        expect(error[:source][:pointer]).to eq('')
      end
    end
  end
end
