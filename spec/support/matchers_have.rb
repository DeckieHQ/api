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
    singularize = options[:singularize]

    key = options[:key]

    relationship = key || attribute.to_s

    link = actual.relationships[relationship]['links']['related']

    type = actual.type.singularize

    target = options[:target]

    helper_prefix = singularize ? attribute.to_s.singularize : attribute

    method = target ? :"#{helper_prefix}_url" : :"#{type}_#{helper_prefix}_url"

    url_helpers = Rails.application.routes.url_helpers

    source = target || options[:source]

    args = options[:args] || ""

    link == "#{url_helpers.public_send(method, source)}#{args}"
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
    return false unless Action.with_deleted.any?

    action = Action.with_deleted.find_by(actor: profile, resource: resource, type: type)

    return false unless action

    has_notification_job?(action)
  end
end

RSpec::Matchers.define :have_achievement do |achievement_name|
  match do |record|
    record.badges.map(&:name).include?(achievement_name)
  end
end

RSpec::Matchers.define :have_many_actions do |actors, resource, type|
  match do
    actions = Action.with_deleted.where(resource: resource, type: type).to_a || []

    actions.reject do |action|
      actors.include?(action.actor) && has_notification_job?(action)
    end.empty?
  end
end

def has_notification_job?(action)
  enqueued_jobs.include?({ job: ActionNotifierJob, queue: 'notifications',
    args: [{ '_aj_globalid' => action.to_global_id.to_s }]
  })
end

RSpec::Matchers.define :have_records do |records|
  match do |results|
    resultIds = results.pluck('id').sort

    recordIds = records.pluck('id').sort

    expect(resultIds).to eq(recordIds)
  end
end

RSpec::Matchers.define :have_enqueued_notification_mail_for do |notification|
  match do
    global_id = { '_aj_globalid' => notification.to_global_id.to_s }

    enqueued_jobs.include?({ job: ActionMailer::DeliveryJob, queue: 'mailers',
      args: ['NotificationMailer', 'informations', 'deliver_now', global_id]
    })
  end
end

RSpec::Matchers.define :have_enqueued_welcome_email_for do |user|
  match do
    global_id = { '_aj_globalid' => user.to_global_id.to_s }

    enqueued_jobs.include?({ job: ActionMailer::DeliveryJob, queue: 'mailers',
      args: ['UserMailer', 'welcome_informations', 'deliver_now', global_id]
    })
  end
end
