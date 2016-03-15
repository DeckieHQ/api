require 'rspec/expectations'

RSpec::Matchers.define :have_sent_mail do |expected|
  match { !MailDeliveries.empty? }
end

RSpec::Matchers.define :have_sent_sms do |expected|
  match { !SMSDeliveries.empty? }
end

RSpec::Matchers.define :have_serialized_attributes do |attributes|
  match do |actual|
    actual == JSON.parse(attributes.to_json)
  end
end

RSpec::Matchers.define :have_relationship_link_for do |attribute, object|
  match do |actual|
    url_helpers = Rails.application.routes.url_helpers
    link = actual.relationships[attribute.to_s]["links"]["related"]
    type = actual.type.singularize
    method = object ? :"#{attribute}_url" : :"#{type}_#{attribute}_url"

    link == url_helpers.public_send(method, object)
  end
end

RSpec::Matchers.define :have_unverified do |attribute|
  match do |actual|
    actual.send("#{attribute}_verification_token").nil? &&
    actual.send("#{attribute}_verification_sent_at").nil? &&
    actual.send("#{attribute}_verified_at").nil?
  end
end

RSpec::Matchers.define :have_coordinates_of_address do
  match do |actual|
    result = Geocoder.search([actual.latitude, actual.longitude]).first

    actual.address == result.address && actual.address == actual.slice(
      :street, :postcode, :city, :state, :country
    ).values.compact.join(', ')
  end
end

RSpec::Matchers.define :have_authorization_error do |error_code, options|
  match do |policy|
    policy.public_send("#{options[:on]}?")

    policy.user.errors.added?(:base, error_code)
  end
end
