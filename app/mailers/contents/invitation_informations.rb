class InvitationInformations < SimpleDelegator
  def subject
    I18n.t('mailer.invitation_informations.subject', title: event.title)
  end

  def username
    email
  end

  def details
    I18n.t('mailer.invitation_informations.details',
      sender: "<b>#{sender.display_name}</b>", title: "<b>#{event.title}</b>"
    )
  end

  def invitation_url
    UrlHelpers.front_for("event/#{event.id}")
  end
end
