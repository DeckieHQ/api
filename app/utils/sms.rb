require 'rest-client'

class SMS
  PATH ||= '/messages'

  extend Forwardable

  attr_reader :options

  def_delegator :@options, :[]

  def initialize(options)
    @options = options
    @client  = RestClient::Resource.new(url)
  end

  def deliver_now
    @client[PATH].post(@options)
  end

  private

  def url
    Rails.application.config.sms_settings[:url]
  end
end
