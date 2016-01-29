class ApplicationSMSer
  protected

  def self.sms(options)
    SMS.new(options)
  end
end
