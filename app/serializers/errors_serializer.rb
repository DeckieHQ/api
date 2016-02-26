# Serialize ActiveModel::Errors to json-api
#
# See: http://jsonapi.org/format/#errors
#
class ErrorsSerializer
  def initialize(errors, on:)
    @errors = errors
    @on     = on
  end

  def serialize
    { errors: serialized_errors }
  end

  protected

  attr_reader :errors, :on

  def serialized_errors
    errors.details.map do |field, field_errors|
      field_errors.each_with_index.map do |details, index|
        {
          code:   details[:error].to_s,
          detail: errors[field][index],
          status: status,
          source: source_for(field)
        }
      end
    end.flatten
  end

  def source_for(field)
    return source_for_base if field == :base

    case on
    when :data
      { pointer: "/data/#{field}" }
    when :attributes
      { pointer: "/data/attributes/#{field}" }
    when :page, :sort, :filters, :include
      { parameter: "#{on}[#{field}]" }
    end
  end

  def source_for_base
    case on
    when :data, :attributes
      { pointer: '' }
    when :page, :sort, :filters, :include
      { parameter: on.to_s }
    end
  end

  def status
    [:data, :attributes].include?(on) ? 422 : 400
  end
end
