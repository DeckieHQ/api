class Filters < SearchOption
  def params
    attributes || {}
  end

  private

  def unsupported
    return [params] unless params.kind_of?(Hash)

    @unsupported ||= params.reject do |key, value|
      if value.kind_of?(Hash)
        associations_scopes_include?(key.to_sym, value)
      else
        scopes.include?(key.to_sym)
      end
    end
  end

  def associations_scopes_include?(key, value)
    associations_scopes[key] == value.keys.map(&:to_sym)
  end

  def scopes
    accept[:scopes] || []
  end

  def associations_scopes
    accept[:associations_scopes] || {}
  end
end
