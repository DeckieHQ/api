require 'rspec/expectations'

RSpec::Matchers.define :return_no_content do
  match { response.code == '204' && response.body.empty? }

  failure_message { failure_message_for(:no_content) }
end

{
  bad_request:  400,
  unauthorized: 401,
  forbidden:    403,
  not_found:    404
}.each do |status, code|
  RSpec::Matchers.define :"return_#{status}" do
    match do
      response.code == code.to_s &&
      json_response == { errors: [
        { status: code, detail: I18n.t("failure.#{status}") }
      ]}
    end

    failure_message { failure_message_for(status) }
  end
end

def failure_message_for(status)
  "expected to receive #{status} but received #{response.code} with #{json_response}"
end

RSpec::Matchers.define :return_status_code do |expected|
  match { response.code == expected.to_s }

  failure_message do
    "expected to receive status code #{expected} but received #{response.code}"
  end
end

def returned_errors?(resource_name, options)
  options  = options || {}
  resource = send(resource_name)
  on       = options[:on] || :attributes

  resource.valid?(options[:context]) unless resource.errors.present?

  expected_errors = ErrorsSerializer.new(resource.errors, on: on).serialize

  json_response == expected_errors
end

RSpec::Matchers.define :return_validation_errors do |resource_name, options|
  match do
    response.code == '422' && returned_errors?(resource_name, options)
  end
end

RSpec::Matchers.define :return_search_errors do |resource_name, options|
  match do
    response.code == '400' && returned_errors?(resource_name, options)
  end
end

RSpec::Matchers.define :return_validation_errors_on do |field|
  match do
    response.code == '422' && json_response[:errors].any? do |error|
      error[:source][:pointer] == "/data/attributes/#{field}"
    end
  end
end
