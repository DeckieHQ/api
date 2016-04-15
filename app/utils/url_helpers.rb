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

  def self.front_url_for(action, params: {})
    @front_url ||= ENV.fetch('FRONT_URL', 'http://www.deckie.io')

     URI::join(front_url, "#{action}?#{params.to_query}").to_s
  end

  private

  attr_reader :front_url

  def helpers
    Rails.application.routes.url_helpers
  end
end
