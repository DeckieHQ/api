class Users::SessionsController < Devise::SessionsController
  def create
    super do |user|
      render json: { email: user.email, token: user.authentication_token }, status: :created
      return
    end
  end
end
