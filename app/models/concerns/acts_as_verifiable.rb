module Verifiable
  module Models
    def acts_as_verifiable(attribute, delivery:, token:)
      before_update :"reset_#{attribute}_verification", if: :"#{attribute}_changed?"

      define_method :"generate_#{attribute}_verification_token!" do
        public_send("#{attribute}_verification_token=",   token.call)
        public_send("#{attribute}_verification_sent_at=", Time.now)
        save
      end

      define_method :"verify_#{attribute}!" do
        public_send("#{attribute}_verification_token=", nil)
        public_send("#{attribute}_verified_at=", Time.now)
        save
      end

      define_method :"send_#{attribute}_verification_instructions" do
        delivery
        .public_send("#{attribute}_verification_instructions", self)
        .deliver_now
      end

      define_method :"#{attribute}_verified?" do
        !public_send("#{attribute}_verified_at").nil?
      end

      private

      define_method :"reset_#{attribute}_verification" do
        [
          :verification_token, :verification_sent_at, :verified_at
        ].each do |suffix|
          public_send("#{attribute}_#{suffix}=", nil)
        end
      end
    end
  end
  ApplicationRecord.extend Models
end
