class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  include Pundit

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: -> { render_error_for(:not_found) }

  rescue_from Ambry::NotFoundError, with: -> { render_error_for(:not_found) }

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

  def permited_attributes(record)
    type = (record.is_a?(Class) ? record : record.class).to_s.downcase.pluralize

    method = "permited_attributes_for_#{params[:action]}"

    record_policy = policy(record)

    attributes(type).permit(
      record_policy.public_send(
        record_policy.respond_to?(method) ? method : :permited_attributes
      )
    )
  end

  def authenticate!(options={})
    authenticate || render_error_for(:unauthorized)
  end

  def authenticate
    authenticate_with_http_token do |token, options|
      user = User.find_by(authentication_token: token)

      return false unless user

      sign_in(user, store: false)
    end
  end

  def render_validation_errors(model, on: :attributes, status: :unprocessable_entity)
    errors = ErrorsSerializer.new(model.errors, on: on).serialize

    render json: errors, status: status
  end

  def render_search_errors(search)
    errors = [:page, :sort, :filters, :include].inject([]) do |errs, type|
      errs.concat(
        ErrorsSerializer.new(search.errors[type], on: type).serialize[:errors]
      )
    end
    render json: { errors: errors }, status: :bad_request
  end

  def render_include_errors(included)
    render_validation_errors(included, on: :include, status: :bad_request)
  end

  def render_service_error(result)
    errors = ServiceErrorSerializer.new(result).serialize

    render json: errors, status: :unprocessable_entity
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
