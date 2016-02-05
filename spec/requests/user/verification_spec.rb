require 'rails_helper'

RSpec.describe 'User verification', :type => :request do
  let(:params) { Serialize.params(verification_params, type: :verifications) }

  before do
    SMSDeliveries.use_fake_provider

    put user_verifications_path, params: params, headers: json_headers
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
    end

    [:email, :phone_number].each do |type|
      context "with type #{type}" do
        let(:verification_params) do
          user_token = user.send("#{type}_verification_token")

          { type: type, token: user_token }
        end

        before do
          user.reload
        end

        context "when user #{type} is not verified" do
          let(:user) { FactoryGirl.create(:"user_with_#{type}_verification") }

          it { is_expected.to return_no_content }

          it "completes user #{type} verification" do
            verified_at = user.send("#{type}_verified_at")

            expect(verified_at).to equal_time(Time.now)
          end
        end

        context "when user #{type} is already verified" do
          let(:user) { FactoryGirl.create(:"user_with_#{type}_verified") }

          it { expect_validation_errors_on_complete }
        end

        context "when #{type} verification token has expired" do
          let(:user) { FactoryGirl.create(:"user_with_#{type}_verification_expired") }

          it { expect_validation_errors_on_complete }
        end

        context "when #{type} verification token is blank" do
          let(:user) { FactoryGirl.create(:user_with_phone_number) }

          let(:verification_params) do
            { type: type, token: Faker::Internet.password }
          end

          it { expect_validation_errors_on_complete }
        end
      end
    end

    def expect_validation_errors_on_complete
      is_expected.to return_validation_errors :verification, context: :complete
    end
  end
end
