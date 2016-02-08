class ValidationExpectations
  def initialize(instance, field, options = {})
    @instance = instance
    @field    = field
    @options  = options
  end

  protected

  def valid?(value)
    @instance[@field] = value

    @instance.valid? || !@instance.errors.include?(@field)
  end
end
