require 'rails_helper'

RSpec.describe 'Users verification instructions', :type => :request do
  let(:verification_params) {}

  before do
    SMSDeliveries.use_fake_provider

    params = {
      data: { type: 'verifications', attributes: verification_params }
    }
    post user_verifications_path, params: params, headers: json_headers
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

    context 'without parameters root' do
      let(:verification_params) {}

      it { is_expected.to return_bad_request }
    end

    context 'with invalid type' do
      let(:verification_params) { { type: :invalid } }

      it { is_expected.to return_validation_errors :verification }
      it { is_expected.not_to have_sent_mail }
      it { is_expected.not_to have_sent_sms  }
    end

    { email: 'Mail', phone_number: 'SMS' }.each do |type, delivery|
      context "with type #{type}" do
        let(:verification_params) { { type: type } }

        context "when user #{type} is not verified" do
          let(:user) { FactoryGirl.create(:user_with_phone_number) }

          before do
            user.reload
          end

          it { is_expected.to return_no_content }

          it "verifies the user" do
            expect(user).to_not have_unverified type
          end

          it "sends a #{delivery} with verification instructions" do
            last_delivery = "#{delivery}Deliveries".constantize.last

            carrier = "User#{delivery}er".constantize

            expect(last_delivery).to send("equal_#{delivery.downcase}",
              carrier.send("#{type}_verification_instructions", user)
            )
          end
        end

        context "when user #{type} is already verified" do
          let(:user) { FactoryGirl.create(:"user_with_#{type}_verified") }

          it do
            is_expected.to return_validation_errors :verification,
              context: :send_instructions
          end

          it { is_expected.not_to have_sent_mail }
          it { is_expected.not_to have_sent_sms  }
        end
      end
    end
  end
end
