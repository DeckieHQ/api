require 'rails_helper'

RSpec.describe NotificationMailer do
  let(:notification) { FactoryGirl.create(:notification)  }

  describe '#informations' do
    let(:mail) { described_class.informations(notification) }

    let(:content) do
      I18n.locale = notification.user.culture

      NotificationInformations.new(notification)
    end

    it 'sets the subject' do
      expect(mail.subject).to eq(content.subject)
    end

    it 'adds the default email signature to the senders' do
      expect(mail.from).to eq([
        ENV.fetch('EMAIL_SIGNATURE', 'no-reply@example.com')
      ])
    end

    it 'adds the user to the receivers' do
      expect(mail.to).to eq([notification.user.email])
    end

    it 'greets the user' do
      expect(mail.body.encoded).to include(
        I18n.t('mailer.greetings', username: content.username, locale: notification.user.culture)
      )
    end

    %w(details link).each do |key|
      it "assigns label #{key}" do
        expect(mail.body.encoded).to include(
          CGI.escapeHTML(
            I18n.t("mailer.notification_informations.#{key}", locale: notification.user.culture)
          )
        )
      end
    end

    [:description, :notification_url].each do |attribute|
      it "assigns #{attribute}" do
        expect(mail.body.encoded).to include(content.public_send(attribute))
      end
    end
  end
end
