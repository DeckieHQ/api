class User::SessionsController < Devise::SessionsController
  before_action -> { check_root_for :user }

  def create
    super do |user|
      response = { email: user.email, token: user.authentication_token }

      render json: response, status: :created and return
    end
  end

  protected

  def check_root_for(root_name)
    render_bad_request unless params[root_name]
  end
end
