class InvitationMailer < ApplicationMailer
  def informations(invitation)
    @content = InvitationInformations.new(invitation)

    change_locale_for(invitation.user) do
      mail(to: invitation.email, subject: content.subject)
    end
  end
end
