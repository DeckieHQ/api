class RegistrationsController < Devise::RegistrationsController
  alias_method :authenticate_user!, :authenticate!

  respond_to :json

  def create
    super do |user|
      if user.persisted?
        render json: { token: user.authentication_token }, status: 201
      else
        render json: { errors: user.errors }, status: 422
      end
      return
    end
  end

  def update
    super do |user|
      if user.save
        render json: user, status: 200
      else
        render json: { errors: user.errors }, status: 422
      end
      return
    end
  end

  private

  def sign_up_params
    params
    .require(resource_name)
    .permit(:first_name, :last_name, :birthday, :email, :password)
  end

  def account_update_params
    params
    .require(resource_name)
    .permit(:first_name, :last_name, :birthday, :email, :phone_number)
  end
end
