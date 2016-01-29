module Token
  extend self

  def friendly
    Devise.friendly_token
  end

  def pin
    rand(100000..999999)
  end
end
