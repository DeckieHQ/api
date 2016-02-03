module Token
  extend self

  # Either friendly or pin are not tested against collisions. Do not use
  # one of these token generators to generate a token used to retrieve an
  # entity by its token.
  #
  # For this specific case, checkout ActiveRecord::SecureToken (add in Rails 5).

  def friendly
    Devise.friendly_token
  end

  def pin
    rand(100000..999999)
  end
end
