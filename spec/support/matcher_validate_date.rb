require_relative './validation_expectations'
require 'rspec/expectations'

class DateExpectations < ValidationExpectations
  def validate_after?
    valid?(day_after_limit) && !valid?(day_limit)
  end

  def validate_before?
    valid?(day_limit) && !valid?(day_after_limit)
  end

  private

  def day_limit
    @limit ||= Time.now - @interval
  end

  def day_after_limit
    @day_after_limit ||= day_limit + 1.day
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
