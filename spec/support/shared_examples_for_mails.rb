RSpec.shared_examples 'a mail with' do |type, options = {}|
  greets_user = options[:greets_user]
  labels      = options[:labels]     || []
  attributes  = options[:attributes] || []

  it 'sets the subject' do
    expect(mail.subject).to eq(content.subject)
  end

  it 'adds the default email signature to the senders' do
    expect(mail.from).to eq([
      ENV.fetch('EMAIL_SIGNATURE', 'no-reply@example.com')
    ])
  end

  it 'adds the user email to the receivers' do
    expect(mail.to).to eq([user.email])
  end

  if greets_user
    it 'greets the user' do
      expect(mail.body.encoded).to include(
        I18n.t('mailer.greetings', username: content.username, locale: user.culture)
      )
    end
  end

  labels.each do |key|
    it "assigns label #{key}" do
      expect(mail.body.encoded).to include(
        CGI.escapeHTML(
          I18n.t("mailer.#{type}.#{key}", locale: user.culture)
        )
      )
    end
  end

  attributes.each do |attribute|
    it "assigns attribute #{attribute}" do
      expect(mail.body.encoded).to include(content.public_send(attribute))
    end
  end
end
