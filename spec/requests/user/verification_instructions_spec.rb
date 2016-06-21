require 'rails_helper'

RSpec.describe 'User verification instructions', :type => :request do
  let(:params) { Serialize.params(verification_params, type: :verifications) }

  let(:sms_fake) { { status: 200 } }

  before do
    SMSDeliveries.use_fake_provider(sms_fake)

    post user_verification_path, params: params, headers: json_headers
  end

  after do
    MailDeliveries.clear
    SMSDeliveries.clear
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)          { FactoryGirl.create(:user) }
    let(:authenticate)  { user }

    let(:verification) do
      Verification.new(verification_params, model: user)
    end

    include_examples 'check parameters for', :verifications

    context 'with invalid type' do
      let(:verification_params) { { type: :invalid } }

      it { is_expected.to return_validation_errors :verification }

      it { is_expected.to_not have_sent_mail }
      it { is_expected.to_not have_sent_sms  }
    end

    { email: 'Mail', phone_number: 'SMS' }.each do |type, delivery|
      context "with type #{type}" do
        let(:verification_params) { { type: type } }

        context "when user's #{type} is not verified" do
          let(:user) { FactoryGirl.create(:user_with_phone_number) }

          before { user.reload }

          it { is_expected.to return_no_content }

          it "generates verification token for the user" do
            expect(user).to_not have_unverified(type)
          end

          it "sends a #{delivery} with verification instructions" do
            last_delivery = "#{delivery}Deliveries".constantize.last

            carrier = "User#{delivery}er".constantize

            expect(last_delivery).to send(
              "equal_#{delivery.downcase}",
              carrier.send("#{type}_verification_instructions", user)
            )
          end

          if type == :phone_number
            context "when user's phone_number is unassigned" do
              let(:sms_fake) { { status: 400, body: user.phone_number } }

              it { is_expected.to return_service_error(:phone_number_unassigned) }
            end
          end
        end

        context "when user's #{type} is already verified" do
          let(:user) { FactoryGirl.create(:"user_with_#{type}_verified") }

          it { is_expected.to return_authorization_error(:"#{type}_already_verified") }

          it { is_expected.to_not send("have_sent_#{delivery.downcase}") }
        end
      end
    end
  end
end
