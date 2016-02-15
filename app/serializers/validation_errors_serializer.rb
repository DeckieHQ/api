# Serialize ActiveModel::Errors to json-api
#
# See: http://jsonapi.org/format/#errors
#
class ValidationErrorsSerializer
  def initialize(object, on:)
    @object = object
    @on     = on
  end

  def serialize
    { errors: serialized_errors }
  end

  protected

  attr_reader :object, :on

  def serialized_errors
    object.errors.details.map do |field, field_errors|
      field_errors.each_with_index.map do |errors, index|
        {
          status: 422,
          code: errors[:error].to_s,
          detail: object.errors[field][index],
          source: source_for(field)
        }
      end
    end.flatten
  end

  def source_for(field)
    return { pointer: '' } if field == :base

    case on
    when :data
      { pointer: "/data/#{field}" }
    when :attributes
      { pointer: "/data/attributes/#{field}" }
    when :page, :sort, :filter
      { parameter: "#{on}[#{field}]" }
    end
  end
end
