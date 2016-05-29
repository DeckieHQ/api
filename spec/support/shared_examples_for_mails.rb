RSpec.shared_examples 'a mail with' do |type, options = {}|
  greets_user = options[:greets_user],
  to          = options[:to]         || :user
  labels      = options[:labels]     || []
  attributes  = options[:attributes] || []

  it 'sets the subject' do
    expect(mail.subject).to eq(content.subject)
  end

  it 'adds the default email signature to the senders' do
    expect(mail.from).to eq([
      Rails.application.config.action_mailer.default_options[:from]
    ])
  end

  it "adds the #{to} email to the receivers" do
    expect(mail.to).to eq([public_send(to).email])
  end

  if greets_user
    it 'greets the user' do
      expect(mail.body.encoded).to include(
        I18n.t('mailer.greetings', username: content.username, locale: culture)
      )
    end
  end

  labels.each do |key|
    it "assigns label #{key}" do
      expect(mail.body.encoded).to include(
        CGI.escapeHTML(
          I18n.t("mailer.#{type}.#{key}", locale: culture)
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
