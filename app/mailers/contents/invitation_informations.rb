class InvitationInformations < SimpleDelegator
  delegate :short_description, to: :event

  def subject
    I18n.t('mailer.invitation_informations.subject', display_name: sender.display_name, title: event.title)
  end

  def details
    I18n.t('mailer.invitation_informations.subject',
      display_name: "<b>#{sender.display_name}</b>", title: "<b>#{event.title}</b>"
    )
  end

  def when
    I18n.t('mailer.invitation_informations.when', begin_at: "<b>#{event.begin_at}</b>")
  end

  def address
    I18n.t('mailer.invitation_informations.address',
      street: event.street, city: event.city, state: event.state, country: event.country
    )
  end

  def capacity_range
    I18n.t('mailer.invitation_informations.capacity_range',
      min_capacity: event.min_capacity, capacity: event.capacity
    )
  end

  def invitation_url
    UrlHelpers.front_for("event/#{event.id}")
  end
end
