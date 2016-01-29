require 'rspec/expectations'

RSpec::Matchers.define :equal_time do |expected|
  match do |actual|
    actual.to_s(:number) == expected.to_s(:number)
  end
end

RSpec::Matchers.define :equal_serialized do |expected|
  match do |actual|
    actual == ActiveModel::SerializableResource.new(expected).to_json
  end
end

RSpec::Matchers.define :equal_mail do |expected|
  match do |actual|
    attributes(actual) == attributes(expected)
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
