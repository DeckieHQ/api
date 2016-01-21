class PasswordsController < Devise::PasswordsController
  def create
    super do |user|
      if user.persisted?
        head :no_content
      else
        render_not_found
      end
      return
    end
  end

  def update

  end
end
