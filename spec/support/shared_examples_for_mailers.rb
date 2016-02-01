require 'set'

EMAIL_DOMAIN_NAME = 'deckie.io'

RSpec.shared_examples 'renders the email headers with' do |options|

  it 'renders the subject' do
    expect(mail.subject).to eq options[:subject]
  end

  it 'renders the receiver email' do
    expect(mail.to).to eq [send(options[:to]).email]
  end

  it 'renders the sender email' do
    expect(mail.from).to eq retrieve_address_for(options[:from])
  end

  it 'renders the reply to email' do
    expect(mail.reply_to).to eq retrieve_address_for(options[:reply_to])
  end

  private

  def retrieve_address_for(type)
    ["#{type}@#{EMAIL_DOMAIN_NAME}"]
  end
end

RSpec.shared_examples 'assigns' do |obj_name, attribute|
  it "assigns @#{obj_name}.#{attribute}" do
    expect(mail.body.encoded).to include(send(obj_name).send(attribute))
  end
end
