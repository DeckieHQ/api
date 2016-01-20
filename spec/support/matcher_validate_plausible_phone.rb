require_relative './validation_expectations'
require 'rspec/expectations'

class PhoneExpectations < ValidationExpectations
  PLAUSIBLE_SAMPLES = {
    '+33652796793' => true,
    'lol'          => false,
    '0652796793'   => false
  }

  def plausible?
    PLAUSIBLE_SAMPLES.each do |phone_number, should_be_valid|
      return false if valid?(phone_number) != should_be_valid
    end
  end
end

RSpec::Matchers.define :validate_plausible_phone do |field|
  match do |instance|
    PhoneExpectations.new(instance, field).plausible?
  end
end
