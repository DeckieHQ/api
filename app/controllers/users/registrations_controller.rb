class Users::RegistrationsController < Devise::RegistrationsController
  alias_method :authenticate_user!, :authenticate!

  def create
    super do |user|
      return render_validation_errors(user) unless user.persisted?

      render json: user, status: :created
      return
    end
  end

  def update
    super do |user|
      return render_validation_errors(user) unless user.valid?

      render json: user, status: :ok and return
    end
  end

  def destroy
    super { head :no_content and return }
  end

  protected

  def sign_up_params
    params
    .require(resource_name)
    .permit(:email, :password, :first_name, :last_name, :birthday)
  end

  def account_update_params
    params
    .require(resource_name).permit(
      :email,      :password,   :current_password,
      :first_name, :last_name,  :birthday, :phone_number
    )
  end
end
