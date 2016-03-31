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

RSpec::Matchers.define :have_relationship_link_for do |attribute, options = {}|
  match do |actual|
    url_helpers = Rails.application.routes.url_helpers
    link = actual.relationships[attribute.to_s]['links']['related']
    type = actual.type.singularize
    source = options[:source]

    method = source ? :"#{attribute}_url" : :"#{type}_#{attribute}_url"

    link == url_helpers.public_send(method, source)
  end
end

RSpec::Matchers.define :have_been_changed do
  match do |actual|
    expected = actual.to_json

    actual.reload.to_json != expected
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

RSpec::Matchers.define :have_created_action do |profile, resource, type|
  match do
    Action.any? && Action.find_by(actor: profile, resource: resource, type: type)
  end
end

RSpec::Matchers.define :have_many_actions do |actors, resource, type|
  match do
    actions = Action.where(resource: resource, type: type).to_a || []

    actions.reject { |action| actors.include?(action.actor) }.empty?
  end
end
