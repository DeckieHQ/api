class ValidationExpectations
  def initialize(instance, field, interval = nil)
    @instance = instance
    @field    = field
    @interval = interval
  end

  protected

  def valid?(value)
    @instance[@field] = value
    @instance.valid? || @instance.errors.details[@field].empty?
  end
end
