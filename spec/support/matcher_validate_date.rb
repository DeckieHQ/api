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
    !valid?(day_limit) && valid?(day_limit + time)
  end

  def day_limit
    @day_limit ||= Time.now - @interval
  end
end

[:after, :before].each do |matcher|
  RSpec::Matchers.define :"validate_date_#{matcher}" do |field, interval|
    match do |instance|
      date_expectations = DateExpectations.new(instance, field, interval)
      date_expectations.send(:"validate_#{matcher}?")
    end
  end
end
