module UrlHelpers
  extend self

  def self.method_missing(method_name, *args)
    self.class.class_eval do
      define_method(method_name) do |*params|
        helpers.public_send(:"#{method_name}_url", params)
      end
    end
    public_send(method_name, args)
  end

  private

  def helpers
    Rails.application.routes.url_helpers
  end
end
