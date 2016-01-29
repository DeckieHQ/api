require 'rest-client'

class SMS
  extend Forwardable

  attr_reader :options

  URL  = Rails.application.config.sms_settings[:url]
  PATH = '/messages'

  def_delegator :@options, :[]

  def initialize(options)
    @options = options
    @client  = RestClient::Resource.new(URL)
  end

  def deliver_now
    @client[PATH].post(@options)
  end
end
