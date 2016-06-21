require 'webmock'

class FakeSMSProvider
  include WebMock::API

  URL  = Rails.application.config.sms_settings[:url]
  PATH = '/messages'

  def initialize(deliveries, status:, body:)
    stub_request(:post, "#{URL}#{PATH}").with do |request|
      options = Rack::Utils.parse_nested_query(request.body).symbolize_keys

      deliveries.push(SMS.new(options))
    end.to_return(status: status, body: body)
  end
end

module SMSDeliveries
  extend self
  extend Forwardable

  @deliveries = []

  def_delegators :@deliveries, :last, :clear, :empty?, :count

  def use_fake_provider(status: 200, body: '')
    FakeSMSProvider.new(deliveries, status: status, body: body)
  end

  protected

  attr_reader :deliveries
end
