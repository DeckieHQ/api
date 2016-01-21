require 'rspec/expectations'

RSpec::Matchers.define :return_no_content do
  match { response.code == '204' && response.body.empty? }

  failure_message { failure_message_for(:no_content) }
end

RSpec::Matchers.define :return_not_found do
  match do
   response.code == '404' &&
   json_response == { error: I18n.t('failure.not_found') }
  end

  failure_message { failure_message_for(:not_found) }
end

def failure_message_for(status)
  "expected to receive :not_found but received #{response.code} with #{json_response}"
end

RSpec::Matchers.define :return_status_code do |expected|
  match { response.code == expected.to_s }

  failure_message do
    "expected to receive status code #{expected} but received #{response.code}"
  end
end

RSpec::Matchers.define :return_validation_errors do |resource_name|
  match do
    resource = send(resource_name)

    resource.valid?

    json_response == { errors: resource.errors.messages }
  end
end
