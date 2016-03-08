class Include < SearchOption
  def params
    @params ||= attributes.to_s.split(',')
  end

  private

  def unsupported
    @unsupported ||= params.reject do |param|
      accept.include?(param)
    end
  end
end
