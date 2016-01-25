require 'rspec/expectations'

RSpec::Matchers.define :have_sent_mail do |expected|
  match { !MailDeliveries.empty? }
end

RSpec::Matchers.define :have_serialized_attributes do |attributes|
  match do |actual|
    actual == JSON.parse(attributes.to_json)
  end
end

RSpec::Matchers.define :have_unverified do |attribute|
  match do |actual|
    actual.send("#{attribute}_verification_token").nil? &&
    actual.send("#{attribute}_verification_sent_at").nil? &&
    actual.send("#{attribute}_verified_at").nil?
  end
end
