require_relative './validation_expectations'
require 'rspec/expectations'

class DateExpectations < ValidationExpectations
  def validate_after?
    validate?(1.day)
  end

  def validate_before?
    validate?(-1.day)
  end

  private

  def validate?(time)
    !valid?(@limit) && valid?(@limit + time)
  end
end

[:after, :before].each do |matcher|
  RSpec::Matchers.define :"validate_date_#{matcher}" do |field, day_limit|
    match do |instance|
      date_expectations = DateExpectations.new(instance, field, day_limit)
      date_expectations.send(:"validate_#{matcher}?")
    end
  end
end
