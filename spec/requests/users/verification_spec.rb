require 'rails_helper'

RSpec.describe 'Users verification', :type => :request do
  let(:verification_params) {}

  before do
    SMSDeliveries.use_fake_provider

    params = { verification: verification_params }

    put users_verifications_path, params: params, headers: json_headers
  end

  after do
    MailDeliveries.clear
    SMSDeliveries.clear
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)          { FactoryGirl.create(:user) }
    let(:authenticated) { true }

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

          it do
            is_expected.to return_validation_errors :verification,
              context: :complete
          end
        end

        context "when #{type} verification token has expired" do
          let(:user) { FactoryGirl.create(:"user_with_#{type}_verification_expired") }

          it do
            is_expected.to return_validation_errors :verification,
              context: :complete
          end
        end

        context "when #{type} verification token is blank" do
          let(:user) { FactoryGirl.create(:user_with_phone_number) }

          it do
            is_expected.to return_validation_errors :verification,
              context: :complete
          end
        end

        context "when #{type} verification token is blank" do
          let(:user) { FactoryGirl.create(:user_with_phone_number) }

          let(:verification_params) do
            { type: type, token: Faker::Internet.password }
          end

          it do
            is_expected.to return_validation_errors :verification,
              context: :complete
          end
        end
      end
    end
  end
end
