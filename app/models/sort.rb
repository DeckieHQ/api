class Sort < SearchOption
  def params
    @params ||= options.map do |attribute, order|
      "#{pluralize_associations(attribute)} #{order}"
    end.join(', ')
  end

  def joins
    associations = []

    keys.each do |key|
      associations.concat(key.split('.').tap(&:pop))
    end
    associations.map(&:to_sym)
  end

  private

  def options
    @options ||= attributes.to_s.split(',').map do |attribute|
      if attribute.chr == '-' && attribute.length > 1
        attribute.slice!(0)

        order = :desc
      else
        order = :asc
      end
      [attribute, order]
    end
  end

  def keys
    @keys ||= options.map(&:first)
  end

  def unsupported
    @unsupported ||= keys.reject do |key|
      accept.include?(key)
    end
  end

  def pluralize_associations(attribute)
    nested_attributes = attribute.split('.')

    column = nested_attributes.pop

    nested_attributes.map(&:pluralize).push(column).join('.')
  end
end
