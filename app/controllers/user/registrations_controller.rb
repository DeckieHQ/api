class User::RegistrationsController < Devise::RegistrationsController
  alias_method :authenticate_user!, :authenticate!

  before_action :authenticate!, only: :show

  def show
    render json: current_user
  end

  def create
    super do |user|
      return render_validation_errors(user) unless user.persisted?

      render json: user, status: :created and return
    end
  end

  def update
    super do |user|
      # If current_password is invalid, devise is not setting properly
      # the user (user.valid? will be true but errors will still appear in
      # user.errors).
      return render_validation_errors(user) if user.errors.present?

      render json: user and return
    end
  end

  def destroy
    CleanAccount.new(current_user).call

    super { head :no_content and return }
  end

  protected

  def sign_up_params
    attributes(:users).permit(shared_attributes, subscriptions: [])
  end

  def account_update_params
    attributes(:users).permit(
      shared_attributes.push(:current_password), subscriptions: []
    )
  end

  def shared_attributes
    [:email, :password, :first_name, :last_name, :birthday, :phone_number, :culture]
  end
end
