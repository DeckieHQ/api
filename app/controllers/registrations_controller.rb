class RegistrationsController < Devise::RegistrationsController
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

  private

  def sign_up_params
    params
    .require(resource_name)
    .permit(:first_name, :last_name, :birthday, :email, :password)
  end
end
