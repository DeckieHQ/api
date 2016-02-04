class User::PasswordsController < Devise::PasswordsController
  before_action -> { check_root_for resource_name }

  def create
    super do |user|
      return render_not_found unless user.persisted?

      head :no_content and return
    end
  end

  def update
    super do |user|
      # Devise sets the user.reset_password_token when the user can be retrieved
      # and the attributes to update the password are invalid.
      #
      # We can't rely on user.valid? as when the user can't be retrieved,
      # Devise returns an empty user (which obviously will be invalid).
      return render_validation_errors(user) if user.reset_password_token

      return render_not_found unless user.persisted?

      head :no_content and return
    end
  end

  protected

  def resource_params
    params.require(:data).require(:attributes).permit(
      :email, :reset_password_token, :password, :password_confirmation
    )
  end
end
