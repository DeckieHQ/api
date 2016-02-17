class Sort < SearchOption
  def params
    @params ||= attributes.to_s.split(',').map do |attribute|
      if attribute.chr == '-'
        attribute.slice!(0) if attribute.length > 1

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
