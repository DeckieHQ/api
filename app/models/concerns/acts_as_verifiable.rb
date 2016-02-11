module Verifiable
  module Models
    def acts_as_verifiable(attribute, delivery:, token:)
      before_update :"reset_#{attribute}_verification", if: :"#{attribute}_changed?"

      define_method :"generate_#{attribute}_verification_token!" do
        self.send("#{attribute}_verification_token=",   token.call)
        self.send("#{attribute}_verification_sent_at=", Time.now)
        self.save
      end

      define_method :"verify_#{attribute}!" do
        self.send("#{attribute}_verification_token=", nil)
        self.send("#{attribute}_verified_at=", Time.now)
        self.save
      end

      define_method :"send_#{attribute}_verification_instructions" do
        delivery
        .send("#{attribute}_verification_instructions", self)
        .deliver_now
      end

      define_method :"#{attribute}_verified?" do
        !self.send("#{attribute}_verified_at").nil?
      end

      private

      define_method :"reset_#{attribute}_verification" do
        [
          :verification_token, :verification_sent_at, :verified_at
        ].each do |suffix|
          self.send("#{attribute}_#{suffix}=", nil)
        end
      end
    end
  end
  ApplicationRecord.extend Models
end
