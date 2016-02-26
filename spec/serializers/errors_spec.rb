require 'rails_helper'

RSpec.shared_examples 'a serialized validation error' do
  it 'has the model validation error code' do
    expected_code = @errors.last[:error].to_s

    expect(error[:code]).to eq expected_code
  end

  it 'has the model validation error detail' do
    expected_detail = model.errors.messages[@field].last

    expect(error[:detail]).to eq expected_detail
  end
end

RSpec.describe ErrorsSerializer, :type => :serializer do
  describe '#serialize' do
    let(:error) do
      ErrorsSerializer.new(model.errors, on: on).serialize[:errors].last
    end

    before do
      @field, @errors = model.errors.details.to_a.last
    end

    describe 'each error' do
      let(:model) { User.new.tap(&:valid?) }

      [:data, :attributes].each do |type|
        context "on #{type}" do
          let(:model) { User.new.tap(&:valid?) }

          let(:on) { type }

          it_behaves_like 'a serialized validation error'

          it 'has a :bad_request status' do
            expect(error[:status]).to eq 422
          end

          context 'with any field error' do
            it 'has a source pointer to the data field' do
              prefix = type == :attributes ? '/data' : ''

              expect(error[:source][:pointer]).to eq("#{prefix}/#{type}/#{@field}")
            end
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
      end

      [:page, :sort, :filters, :include].each do |type|
        context "on #{type}" do
          let(:model) { Page.new(number: -1, size: 60).tap(&:valid?) }
          let(:on)    { type }

          it_behaves_like 'a serialized validation error'

          it 'has a :bad_request status' do
            expect(error[:status]).to eq 400
          end

          context 'with any field error' do
            it 'has a source parameter to the URI query parameter' do
              expect(error[:source][:parameter]).to eq "#{type}[#{@field}]"
            end
          end

          context 'with base error' do
            before do
              model.errors.add(:base, :invalid)
            end

            it 'has an source parameter to the URI query parameter top-level' do
              expect(error[:source][:parameter]).to eq(type.to_s)
            end
          end
        end
      end
    end
  end
end
