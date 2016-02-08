require_relative './validation_expectations'
require 'rspec/expectations'

class DateTimeExpectations < ValidationExpectations
  def validate_after?
    validate?(compare)
  end

  def validate_before?
    validate?(-compare)
  end

  private

  def validate?(time)
    !valid?(limit) && valid?(limit + time)
  end

  def limit
    limit_option = @options[:limit]

    return limit_option unless limit_option.is_a?(Symbol)

    @instance.send("#{limit_option}=", fake_time)
  end

  def compare
    1.send(@options[:on] || :day)
  end

  def fake_time
    Faker::Time.between(100.years.ago, Time.now + 100.years, :all)
  end
end

[:after, :before].each do |matcher|
  RSpec::Matchers.define :"validate_date_#{matcher}" do |field, options|
    match do |instance|
      date_expectations = DateTimeExpectations.new(instance, field, options)

      date_expectations.send(:"validate_#{matcher}?")
    end
  end
end
