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
