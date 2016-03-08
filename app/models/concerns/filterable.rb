# Call scopes directly from the URL params:
#
# @products = Product.filter(params[:filters].slice(:status, :location))
#
# Supports scope invokations without parameters:
#
# e.g. Events.filter(:opened)
#
module Filterable
  extend ActiveSupport::Concern

  module ClassMethods

    # Call the class methods with the same name as the keys in params with their
    # associated values. Most useful for calling named scopes from URL params.
    # Make sure you don't pass stuff directly from the web without whitelisting
    # only the params you care about first! Individual Scopes must also be
    # bulletproof against any kind of parameters (Hash, String, etc...).
    def filter(params)
      return anonymous_scope.public_send(params) unless params.kind_of?(Hash)

      params.keys.inject(anonymous_scope) do |results, key|
        results.public_send(key, params[key])
      end
    end

    private

    def anonymous_scope
      where(nil)
    end
  end
end
