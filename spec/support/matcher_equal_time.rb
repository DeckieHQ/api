require 'rspec/expectations'

RSpec::Matchers.define :equal_time do |expected|
  match do |actual|
    actual.to_s(:number) == expected.to_s(:number)
  end
end
