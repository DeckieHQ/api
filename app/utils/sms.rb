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
    begin
      @client[PATH].post(@options)
    rescue RestClient::ExceptionWithResponse => e
      return false if e.response.code == 400

      raise e
    end
  end

  private

  def url
    Rails.application.config.sms_settings[:url]
  end
end
