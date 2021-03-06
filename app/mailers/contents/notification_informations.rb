class NotificationInformations < SimpleDelegator
  def description
    I18n.t(translation_for(:description),
      display_name: "<b>#{action.actor.display_name}</b>", title: "<b>#{action.title}</b>"
    )
  end

  def url
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
