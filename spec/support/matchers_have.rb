require 'rspec/expectations'

RSpec::Matchers.define :have_sent_mail do |expected|
  match { !MailDeliveries.empty? }
end
