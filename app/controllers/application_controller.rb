class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  protected

  def authenticate!(options={})
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      user = User.find_by(authentication_token: token)

      sign_up(user, store: false)
    end
  end

  def render_unauthorized
    render json: { error: I18n.t('failure.unauthorized') }, status: 401
  end

  def render_validation_errors(model)
    render json: { errors: model.errors }, status: :unprocessable_entity
  end
end
