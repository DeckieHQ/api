require 'rest-client'

class SMS
  URL  = Rails.application.config.sms_settings[:url]
  PATH = '/messages'

  extend Forwardable

  attr_reader :options

  def_delegator :@options, :[]

  def initialize(options)
    @options = options
    @client  = RestClient::Resource.new(URL)
  end

  def deliver_now
    @client[PATH].post(@options)
  end
end
