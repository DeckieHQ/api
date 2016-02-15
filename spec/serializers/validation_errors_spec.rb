require 'rails_helper'

RSpec.shared_examples 'a serialized validation error' do
  it 'has a 422 status' do
    expect(error[:status]).to eq 422
  end

  it 'has the model validation error code' do
    expected_code = @errors.last[:error].to_s

    expect(error[:code]).to eq expected_code
  end

  it 'has the model validation error detail' do
    expected_detail = model.errors.messages[@field].last

    expect(error[:detail]).to eq expected_detail
  end

  context 'with base error' do
    before do
      model.errors.add(:base, :invalid)
    end

    it 'has an empty source pointer' do
      expect(error[:source][:pointer]).to be_blank
    end
  end
end

RSpec.describe ValidationErrorsSerializer, :type => :serializer do
  let(:model) { User.new.tap(&:valid?) }

  describe '#serialize' do
    let(:error) do
      ValidationErrorsSerializer.new(model, on: on).serialize[:errors].last
    end

    before do
      @field, @errors = model.errors.details.to_a.last
    end

    describe 'each error' do
      context 'on attributes' do
        let(:on) { :attributes }

        it_behaves_like 'a serialized validation error'

        context 'with any field error' do
          it 'has a source pointer to the attribute field error' do
            expect(error[:source][:pointer]).to eq "/data/attributes/#{@field}"
          end
        end
      end

      context 'on data' do
        let(:on) { :data }

        it_behaves_like 'a serialized validation error'

        context 'with any field error' do
          it 'has a source pointer to the data field error' do
            expect(error[:source][:pointer]).to eq "/data/#{@field}"
          end
        end
      end
    end

    context 'on page' do
      let(:model) { Page.new(number: -1, size: 60).tap(&:valid?) }
      let(:on)    { :page }

      it_behaves_like 'a serialized validation error'

      context 'with any field error' do
        it 'has a source parameter to the URI query parameter error' do
          expect(error[:source][:parameter]).to eq "page[#{@field}]"
        end
      end
    end
  end
end
