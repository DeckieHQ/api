# Serialize ActiveModel::Errors to json-api
#
# See: http://jsonapi.org/format/#errors
#
module ValidationErrorsSerializer
  extend self

  def serialize(object)
    errors = object.errors.details.map do |field, field_errors|
      field_errors.each_with_index.map do |errors, index|
        pointer = field == :base ? "" : "/data/attributes/#{field}"
        {
          status: 422,
          code: errors[:error].to_s,
          detail: object.errors[field][index],
          source: { pointer: pointer }
        }
      end
    end.flatten

    { errors: errors }
  end
end
