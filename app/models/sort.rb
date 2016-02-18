class Sort < SearchOption
  def params
    @params ||= attributes.to_s.split(',').map do |attribute|
      if attribute.chr == '-' && attribute.length > 1
        attribute.slice!(0)

        order = :desc
      else
        order = :asc
      end
      { attribute.to_sym => order }
    end
  end

  protected

  def unsupported
    @unsupported ||= params.map(&:first).map(&:first).reject do |attribute|
      accept.include?(attribute)
    end
  end
end
