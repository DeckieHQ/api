class ValidationExpectations
  def initialize(instance, field, limit = nil)
    @instance = instance
    @field    = field
    @limit    = limit
  end

  protected

  def valid?(value)
    @instance[@field] = value
    @instance.valid? || @instance.errors.details[@field].empty?
  end
end
