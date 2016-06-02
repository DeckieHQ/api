class NotificationInformations < SimpleDelegator
  def username
    user.email
  end

  def subject
    I18n.t(translation_for(:subject),
      display_name: action.actor.display_name
    )
  end

  def description
    I18n.t(translation_for(:description),
      display_name: action.actor.display_name, title: action.title
    )
  end

  def notification_url
    UrlHelpers.front_for("notification/#{id}")
  end

  private

  def translation_for(key)
    "mailer.notification_informations.#{key}.#{type}.#{address_to}"
  end

  def address_to
    address_directly? ? :address_directly : :third_person
  end

  def address_directly?
    user.profile.id == action.actor.id
  end
end
