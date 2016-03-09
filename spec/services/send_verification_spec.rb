require 'rails_helper'

RSpec.describe SendVerification do
  let(:service) { SendVerification.new(user, verification) }

  describe '#call' do
    subject(:result) { service.call }

    [:email, :phone_number].each do |type|
      generate_verification_token    = :"generate_#{type}_verification_token!"
      send_verification_instructions = :"send_#{type}_verification_instructions"

      context "when verification type is #{type}" do
        let(:user) { FactoryGirl.create(:user) }

        let(:verification) { Verification.new({ type: type }, model: user) }

        before do
          allow(user).to receive(generate_verification_token).and_return(true)
        end

        context 'when send_verification_instructions succeeded' do
          before do
            allow(user).to receive(send_verification_instructions).and_return(true)

            result
          end

          it 'is succesful' do
            is_expected.to be_instructions_sent
          end

          it "generate a verification token" do
            expect(user).to have_received(generate_verification_token)
          end

          it "sends a message with verification instructions" do
            expect(user).to have_received(send_verification_instructions)
          end
        end

        context 'when send_verification_instructions failed' do
          before do
            allow(user).to receive(send_verification_instructions).and_return(false)

            result
          end

          it 'is not succeesful' do
            is_expected.to_not be_instructions_sent
          end

          it 'has an error' do
            expect(result.error).to eq(:"#{type}_unassigned")
          end
        end
      end
    end
  end
end
