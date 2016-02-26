class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: -> { render_error_for(:not_found) }

  protected

  def resource_attributes
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

  def verified!
    current_user.verified? || render_validation_errors(current_user)
  end

  def current_profile
    current_user.profile
  end

  def check_parameters_for(resource_type)
    parameters = Parameters.new(params.to_unsafe_h, resource_type: resource_type.to_s)

    render_validation_errors(parameters, on: :data) unless parameters.valid?
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
