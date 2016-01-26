class Users::SessionsController < Devise::SessionsController
  def create
    super do |user|
      render json: { token: user.authentication_token }, status: :created
      return
    end
  end
end
