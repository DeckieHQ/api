class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  respond_to :json

  protected

  def authenticate!(options={})
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      user = User.find_by(authentication_token: token)

      sign_in(:user, user, store: false, bypass: true)
    end
  end

  def render_not_found
    render json: { error: I18n.t('failure.not_found') }, status: :not_found
  end

  def render_unauthorized
    render json: { error: I18n.t('failure.unauthorized') }, status: :unauthorized
  end

  def render_validation_errors(model)
    errors = {
      details:  model.errors.details,
      messages: model.errors.messages
    }
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
