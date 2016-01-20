class PasswordsController < Devise::PasswordsController
  def create
    super { head :no_content and return }
  end

  def update

  end
end
