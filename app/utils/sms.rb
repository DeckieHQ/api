require 'rest-client'

class SMS
  extend Forwardable

  attr_reader :options

  def_delegator :@options, :[]

  def initialize(options)
    @options = options
    @client  = RestClient::Resource.new(url)
  end

  def deliver_now
    begin
      @client['/messages'].post(options)
    rescue RestClient::ExceptionWithResponse => e
      if e.response.code == 400 && e.response.body.include?(options[:to])
        return false
      end
      raise e
    end
  end

  private

  def url
    Rails.application.config.sms_settings[:url]
  end
end
