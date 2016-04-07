require 'rspec/expectations'

RSpec::Matchers.define :equal_time do |expected|
  match do |actual|
    expect(actual).to be_within(1.second).of(expected)
  end
end

class SerializationContext
  attr_reader :request_url, :query_parameters

  def initialize(request)
    @request_url      = request.original_url[/\A[^?]+/]
    @query_parameters = request.query_parameters
  end
end

RSpec::Matchers.define :equal_serialized do |object|
  match do |actual|
    resource = ActiveModel::SerializableResource.new(object)

    expected = resource.to_json({
      serialization_context: SerializationContext.new(request)
    })
    result = JSON.parse(actual).except('meta').to_json

    result == expected
  end
end

RSpec::Matchers.define :equal_mail do |expected|
  match do |actual|
    actual != nil && attributes(actual) == attributes(expected)
  end

  def attributes(mail)
    mail.instance_values.slice('from', 'reply_to', 'to', 'subject')
  end
end

RSpec::Matchers.define :equal_sms do |expected|
  match do |actual|
    actual.options == expected.options
  end
end
