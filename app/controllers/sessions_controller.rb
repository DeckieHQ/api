class SessionsController < Devise::SessionsController
  respond_to :json

  def create
    super do |user|
      data = { token: user.authentication_token }

      render json: data, status: 201

      return true
    end
  end
end
