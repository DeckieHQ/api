require 'rails_helper'

RSpec.describe ValidationErrorsSerializer, :type => :serializer do
  let(:model) { User.new }

  describe '.serialize' do
    before do
      model.valid?

      @errors = ValidationErrorsSerializer.serialize(model)[:errors]
    end

    it 'serializes the model valdations errors to json api' do
      expect(@errors).to_not be_empty
      expect(@errors).to eql(expected_errors)
    end

    def expected_errors
      model.errors.details.map do |field, field_errors|
        field_errors.each_with_index.map do |errors, index|
          {
            status: 422,
            code: errors[:error].to_s,
            detail: model.errors[field][index],
            source: { pointer: "/data/attributes/#{field}"}
          }
        end
      end.flatten
    end
  end
end
