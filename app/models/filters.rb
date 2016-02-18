class Filters < SearchOption
  def params
    attributes || {}
  end

  protected

  def unsupported
    return [params] unless params.kind_of?(Hash)

    @unsupported ||= params.keys.map(&:to_sym).reject do |filter|
      accept.include?(filter)
    end
  end
end
