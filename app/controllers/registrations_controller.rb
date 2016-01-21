class RegistrationsController < Devise::RegistrationsController
  alias_method :authenticate_user!, :authenticate!

  def create
    super do |user|
      if user.persisted?
        render json: user, status: :created
      else
        render_validation_errors(user)
      end
      return
    end
  end

  def update
    super do |user|
      if user.valid?
        render json: user, status: :ok
      else
        render_validation_errors(user)
      end
      return
    end
  end

  def destroy
    super { head :no_content and return }
  end

  protected

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

  # Skip_current password confirmation for account update.
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end
