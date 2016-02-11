module Verifiable
  module Models
    def acts_as_verifiable(attribute, delivery:, token:)
      before_update :"reset_#{attribute}_verification", if: :"#{attribute}_changed?"

      define_method :"generate_#{attribute}_verification_token!" do
        send("#{attribute}_verification_token=",   token.call)
        send("#{attribute}_verification_sent_at=", Time.now)
        save
      end

      define_method :"verify_#{attribute}!" do
        send("#{attribute}_verification_token=", nil)
        send("#{attribute}_verified_at=", Time.now)
        save
      end

      define_method :"send_#{attribute}_verification_instructions" do
        delivery
        .send("#{attribute}_verification_instructions", self)
        .deliver_now
      end

      define_method :"#{attribute}_verified?" do
        !send("#{attribute}_verified_at").nil?
      end

      private

      define_method :"reset_#{attribute}_verification" do
        [
          :verification_token, :verification_sent_at, :verified_at
        ].each do |suffix|
          send("#{attribute}_#{suffix}=", nil)
        end
      end
    end
  end
  ApplicationRecord.extend Models
end
