require 'rspec/expectations'

RSpec::Matchers.define :be_valid_token do |type|
  match do |actual|
    case type
    when :secure
      actual.is_a?(String) && actual.size == 24
    when :friendly
      actual.is_a?(String) && actual.size == 20
    when :pin
      actual.is_a?(Integer) && actual >= 100000 && actual <= 999999
    end
  end
end
