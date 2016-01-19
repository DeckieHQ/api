require 'rspec/expectations'

RSpec::Matchers.define :return_status_code do |expected|
  match { response.code == expected.to_s }
end

RSpec::Matchers.define :return_validation_errors do |resource_name|
  match do
    resource = send(resource_name)

    resource.valid?

    json_response == { errors: resource.errors.messages }
  end
end
