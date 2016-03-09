class ServiceErrorSerializer
  def initialize(service)
    @service = service
  end

  def serialize
    { errors: errors }
  end

  private

  attr_reader :service

  def errors
    [
      {
        status: 422,
        code: service.error,
        detail: I18n.t("service.errors.#{service.error}"),
        source: { pointer: '' }
      }
    ]
  end
end
