class Filters < SearchOption
  def params
    attributes || {}
  end

  private

  def unsupported
    return [params] unless params.kind_of?(Hash)

    @unsupported ||= params.transform_keys(&:to_sym).reject do |key, value|
      if associations_scopes.include?(key)
        associations_scopes_supports?(key, value)
      else
        scopes.include?(key)
      end
    end
  end

  def associations_scopes_supports?(key, value)
    if value.kind_of?(Hash)
      associations_scopes[key] == value.keys.map(&:to_sym)
    else
      associations_scopes.include?(key)
    end
  end

  def scopes
    accept[:scopes] || []
  end

  def associations_scopes
    accept[:associations_scopes] || {}
  end
end
