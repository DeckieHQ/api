module UrlHelpers
  extend self

  def self.method_missing(method_name)
    self.class.class_eval do
      define_method(method_name) do
        helpers.public_send(:"#{method_name}_url")
      end
    end
    public_send(method_name)
  end

  private

  def helpers
    Rails.application.routes.url_helpers
  end
end
