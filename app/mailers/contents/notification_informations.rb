class NotificationInformations < SimpleDelegator
  def username
    user.email
  end

  def subject
    I18n.t("#{root}.subject.#{type}.#{address_to}",
      display_name: action.actor.display_name)
  end

  def description
    I18n.t("#{root}.description.#{type}.#{address_to}",
      display_name: action.actor.display_name, title: action.title
    )
  end

  def notification_url
    UrlHelpers.front_for("notifications/#{id}")
  end

  private

  def root
    'mailer.notification_informations'
  end

  def address_to
    address_directly? ? :address_directly : :third_person
  end

  def address_directly?
    user.profile.id == action.actor.id
  end
end
