# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] = 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda-matchers'
require 'factory_girl_rails'
require 'algolia/webmock'
require 'pundit/rspec'
require 'carrierwave/test/matchers'

def disable_net_connect!
  WebMock.disable_net_connect!(allow: %w(api.cloudinary.com codeclimate.com maps.googleapis.com))
end

disable_net_connect!

Geocoder.configure(lookup: :test)

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.include RequestHelpers::Json, :type => :request

  config.include FileHelpers::Image

  config.include ActiveJob::TestHelper

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  search_configured = AlgoliaSearch.configuration[:application_id].present? &&
                      AlgoliaSearch.configuration[:api_key].present?

  config.filter_run_excluding type: :search unless search_configured

  if ENV.fetch('CLOUDINARY_URL', '').empty?
    config.filter_run_excluding type: :uploader, upload: :true
  end

  # Search tests requires accessing a real algolia server. Reindexing is quite
  # long, therefore it's mandatory to create records in a before(:all) hook
  # and indexing them only once per index.
  config.before(:all, type: :search) do
    @request_stubs = WebMock::StubRegistry.instance.request_stubs

    WebMock.reset!

    WebMock.allow_net_connect!

    config.use_transactional_fixtures = false
  end

  config.after(:all, type: :search) do
    DatabaseCleaner.clean_with(:truncation)

    config.use_transactional_fixtures = true

    WebMock::StubRegistry.instance.request_stubs = @request_stubs

    disable_net_connect!
  end
end
