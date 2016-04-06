source 'https://rubygems.org'

ruby '2.2.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.beta2'

# JSON Serializers
gem 'active_model_serializers', git: 'git://github.com/rails-api/active_model_serializers'

# Use postgresql as ActiveRecord database
gem 'pg', '~> 0.18'

# Use Puma as the app server
gem 'puma', '~> 2.15'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS),
# making cross-origin AJAX possible
gem 'rack-cors', '~> 0.4'

# Authentication
gem 'devise', git: 'git://github.com/plataformatec/devise.git'

# Mails
gem 'postmark-rails', '~> 0.10'

# HTTP Client
gem 'rest-client', '2.0.0.rc2'

# Validations
gem 'phony_rails', '~> 0.12'
gem 'date_validator', '~> 0.9'

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
gem 'paranoia', git: 'git://github.com/radar/paranoia', branch: 'core'

# Search
gem 'algoliasearch', git: 'git://github.com/foliea/algoliasearch-client-ruby', branch: 'patch-1'
gem 'algoliasearch-rails', '~> 1.14'

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
