require 'rspec/expectations'

RSpec::Matchers.define :return_status_code do |expected|
  match { response.code == expected.to_s }
end
