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

  def self.front_for(action, params: {})
    query = params.empty? ? action : "#{action}?#{params.to_query}"

    URI::join(front, query).to_s
  end

  private

  def self.front
    Rails.application.config.front_url
  end

  def self.front_notifications
    URI::join(self.front, '/account/notifications')
  end

  def helpers
    Rails.application.routes.url_helpers
  end
end
