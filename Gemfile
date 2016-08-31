source 'https://rubygems.org'

ruby '2.2.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.beta2'

# Serializers
gem 'active_model_serializers','~> 0.10'

# Use postgresql as ActiveRecord database
gem 'pg', '~> 0.18'

# Use Puma as the app server
gem 'puma', '~> 2.15'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS),
# making cross-origin AJAX possible
gem 'rack-cors', '~> 0.4'

# Authentication
gem 'devise', '~> 4.2'

# Mails
gem 'postmark-rails', '~> 0.10'

# HTTP Client
gem 'rest-client', '2.0'

# Validations
gem 'phony_rails', '~> 0.12'
gem 'date_validator', '~> 0.9'
gem 'email_validator', '~> 1.6'

# Geolocation
gem 'geocoder', '~> 1.3'

# Pagination
gem 'will_paginate', '~> 3.1'

# Utility
gem 'wannabe_bool', '~> 0.5.0'
gem 'immutable-struct', '~> 2.2'

# Authorizations
gem 'pundit', '~> 1.1'

# Soft-delete records
gem 'paranoia', '~> 2.2.0.pre'

# Search
gem 'algoliasearch', '~> 1.10'
gem 'algoliasearch-rails', '~> 1.14'

# Env
gem 'dotenv-rails', '~> 2.1'

# Jobs
gem 'sidekiq', '~> 4.1'
gem 'sidekiq-scheduler', '~> 2.0'
gem 'sinatra', '~> 2.0.0.beta2', require: nil

# Image upload
gem 'carrierwave', git: 'git://github.com/carrierwaveuploader/carrierwave'
gem 'carrierwave-base64', '~> 2.2'
gem 'cloudinary', '~> 1.1'

# Achievements
gem 'merit', '~> 2.3'

# Exceptions
gem 'raygun4ruby', '~> 1.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 8.2'
  gem 'rspec-rails', '>= 3.5.0.beta2'
end

group :development do
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 1.6'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.4', require: nil
  gem 'shoulda-matchers', '~> 3.1'
  gem 'factory_girl_rails', '~> 4.5'
  gem 'webmock', '~> 1.22'
  gem 'faker', '~> 1.6'
  gem 'pundit-matchers', '~> 1.0'
  gem 'database_cleaner', '~> 1.5'
end

group :production do
  gem 'rails_stdout_logging', '~> 0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
