class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  include Pundit

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: -> { render_error_for(:not_found) }

  rescue_from 'Pundit::NotAuthorizedError' do
    if current_user.errors.empty?
      render_error_for(:forbidden)
    else
      render_validation_errors(current_user)
    end
  end

  rescue_from 'ParametersError' do |exception|
    render_validation_errors(exception, on: :data)
  end

  protected

  def attributes(resource_type)
    parameters = Parameters.new(params.to_unsafe_h, resource_type: resource_type.to_s)

    unless parameters.valid?
      raise ParametersError, errors: parameters.errors
    end
    params.require(:data).require(:attributes)
  end

  def authenticate!(options={})
    authenticate_token || render_error_for(:unauthorized)
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      user = User.find_by(authentication_token: token)

      return false unless user

      sign_in(user, store: false)
    end
  end

  def render_validation_errors(model, on: :attributes)
    errors = ErrorsSerializer.new(model.errors, on: on).serialize

    render json: errors, status: :unprocessable_entity
  end

  def render_search_errors(search)
    errors = [:page, :sort, :filters, :include].inject([]) do |errors, type|
      errors.concat(
        ErrorsSerializer.new(search.errors[type], on: type).serialize[:errors]
      )
    end
    render json: { errors: errors }, status: :bad_request
  end

  def render_error_for(status)
    render json: {
      errors: [{
        status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
        detail: I18n.t("failure.#{status}")
      }]
    }, status: status
  end
end
