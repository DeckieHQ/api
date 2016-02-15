class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  respond_to :json

  protected

  attr_reader :page

  def resource_attributes
    params.require(:data).require(:attributes)
  end

  def page
    @page ||= Page.new(params[:page] || { number: 1, size: 10 })
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

  def verified?
    render_validation_errors(current_user) unless current_user.verified?
  end

  def fetch_pagination
    render_validation_errors(page, on: :page) unless page.valid?
  end

  def check_parameters_for(resource_type)
    parameters = Parameters.new(params, resource_type: resource_type.to_s)

    render_validation_errors(parameters, on: :data) unless parameters.valid?
  end

  def render_error_for(status)
    render json: {
      errors: [{
        status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
        detail: I18n.t("failure.#{status}")
      }]
    }, status: status
  end

  def render_validation_errors(model, on: :attributes)
    errors = ValidationErrorsSerializer.new(model, on: on).serialize

    render json: errors, status: :unprocessable_entity
  end
end
