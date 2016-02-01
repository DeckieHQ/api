# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] = 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda-matchers'
require 'factory_girl_rails'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow: 'codeclimate.com')

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

  config.include Request::JsonHelpers, :type => :request
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
end

# Custom helper to add a generator for plausible phone numbers.
module PhoneNumber
  def plausible
    phone_number = "0#{rand(1..7)}#{rand(10000000..99999999)}"

    PhonyRails.normalize_number(phone_number, country_code: 'FR')
  end
end

Faker::PhoneNumber.extend PhoneNumber
