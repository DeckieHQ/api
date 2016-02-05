class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  respond_to :json

  def resource_attributes
    params.require(:data).require(:attributes)
  end

  protected

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

  def check_parameters_for(root)
    if params['data'] &&
       params['data']['attributes'] &&
       params['data']['type'] == root.to_s.pluralize
      return
    end
    render_error_for(:bad_request)
  end

  def render_error_for(status)
    render json: { error: I18n.t("failure.#{status}") }, status: status
  end

  def render_validation_errors(model)
    errors = {
      details:  model.errors.details,
      messages: model.errors.messages
    }
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
