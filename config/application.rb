require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Deckie
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.generators do |g|
      g.test_framework :rspec
    end

    config.action_mailer.delivery_method = :postmark

    config.action_mailer.postmark_settings = { api_token: ENV['POSTMARK_API_TOKEN'] }

    config.action_mailer.default_options = {
      from: ENV.fetch('EMAIL_SIGNATURE', 'no-reply@example.com')
    }

    config.sms_settings = { url: ENV['BLOWERIO_URL'] }

    config.active_job.queue_adapter = :sidekiq

    config.front_url = ENV['FRONT_URL'] || 'http://www.example.com'

    config.launch_date = Date.strptime('22-08-2016', '%d-%m-%Y')
  end
end
