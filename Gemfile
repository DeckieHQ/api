source 'https://rubygems.org'

ruby '2.2.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 5.0.0.beta1', '< 5.1'

# JSON Serializers
gem 'active_model_serializers', '0.10.0.rc3'

# Use postgresql as ActiveRecord database
gem 'pg', '~> 0.18'

# Use Puma as the app server
gem 'puma', '~> 2.15'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS),
# making cross-origin AJAX possible
gem 'rack-cors', '~> 0.4'

# Authentication
gem 'devise', git: 'git://github.com/plataformatec/devise.git'

# Validations
gem 'phony_rails', '~> 0.12'
gem 'date_validator', '~> 0.9'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 8.2'
  gem 'rspec-rails', '~> 3.1'
end

group :development do
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 1.6'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.4', require: nil
  gem 'shoulda-matchers', '~> 3.0'
  gem 'factory_girl_rails', '~> 4.5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
