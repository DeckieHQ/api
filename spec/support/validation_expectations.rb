class ValidationExpectations
  def initialize(instance, field, options = {})
    @instance = instance
    @field    = field
    @options  = options
  end

  protected

  attr_reader :instance, :field, :options

  def valid?(value)
    instance[field] = value

    instance.valid? || !instance.errors.include?(field)
  end
end
