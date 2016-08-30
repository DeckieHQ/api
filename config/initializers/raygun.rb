Raygun.setup do |config|
  config.api_key = ENV['RAYGUN_APIKEY']

  config.filter_parameters = Rails.application.config.filter_parameters

  config.ignore  << [
    'ActiveRecord::RecordNotFound',
    'Ambry::NotFoundError',
    'Pundit::NotAuthorizedError',
    'ParametersError'
  ]
end
