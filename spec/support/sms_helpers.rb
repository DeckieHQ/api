require 'webmock'

class FakeSMSProvider
  include WebMock::API

  URL  = Rails.application.config.sms_settings[:url]
  PATH = '/messages'

  def initialize(deliveries)
    stub_request(:post, "#{URL}#{PATH}").with do |request|
      options = Rack::Utils.parse_nested_query(request.body).symbolize_keys

      deliveries.push(SMS.new(options))
    end
  end
end

module SMSDeliveries
  extend self
  extend Forwardable

  @deliveries = []

  def_delegators :@deliveries, :last, :clear, :empty?, :count

  def use_fake_provider
    FakeSMSProvider.new(@deliveries)
  end
end
