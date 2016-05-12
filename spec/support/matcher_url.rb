require 'rspec/expectations'

RSpec::Matchers.define :be_an_url do
  match do |actual|
    URI.parse(actual) rescue false
  end
end
