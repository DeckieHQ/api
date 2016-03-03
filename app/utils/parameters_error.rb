class ParametersError < StandardError
  attr_reader :errors

  def initialize(options = {})
    @errors = options[:errors]

    super(errors.full_messages.to_s)
  end
end
