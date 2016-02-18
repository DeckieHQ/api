require 'rails_helper'

RSpec.describe Verification, :type => :model do
  it do
    is_expected.to validate_inclusion_of(:type)
      .in_array(%w(email phone_number))
  end

  let(:user) { FactoryGirl.create(:user_with_phone_number) }

  [:email, :phone_number].each do |attribute|
    let(:base_options) { { type: verification.type, target: :User } }

    describe '#send_instructions' do
      let(:user_send_instructions?) { true }
      let(:sent) { verification.send_instructions }

      before do
        allow(user).to receive(:"generate_#{attribute}_verification_token!")
          .and_return(true)
        allow(user).to receive(:"send_#{attribute}_verification_instructions")
          .and_return(user_send_instructions?)

        sent
      end

      context 'when type is invalid' do
        let(:verification) { Verification.new({ type: nil }, model: user) }

        include_examples 'fails to send verification for', attribute

        it { expect_validation_error_on(:type, :inclusion) }
      end

      context "when type is #{attribute}" do
        let(:verification) { Verification.new({ type: attribute }, model: user) }

        context 'when model has no attribute to verify' do
          let(:user) do
            FactoryGirl.create(:user) do |u|
              u.send("#{attribute}=", nil)
            end
          end

          include_examples 'fails to send verification for', attribute

          it { expect_validation_error_on(:base, :unspecified, base_options) }
        end

        context "when #{attribute} is unassigned" do
          let(:user_send_instructions?) { false }

          it { expect(sent).to be_falsy }

          it { expect_validation_error_on(:base, :unassigned, base_options) }
        end

        context "when #{attribute} is already verified" do
          let(:user) { FactoryGirl.create(:"user_with_#{attribute}_verified") }

          include_examples 'fails to send verification for', attribute

          it { expect_validation_error_on(:base, :already_verified, base_options) }
        end

        context 'when everything is valid' do
          it { expect(sent).to be_truthy }

          it "generate an #{attribute} verification token for the model" do
            expect(verification.model).to have_received(:"generate_#{attribute}_verification_token!")
          end

          it "sends a message with verification instructions to the model #{attribute}" do
            expect(verification.model).to have_received(:"send_#{attribute}_verification_instructions")
          end

          it 'has no error' do
            expect(verification.errors).to be_empty
          end
        end
      end
    end

    describe '#complete' do
      let(:completed) { verification.complete }

      before do
        allow(user).to receive(:"verify_#{attribute}!").and_return(true)

        completed
      end

      context 'when type is invalid' do
        let(:verification) { Verification.new({ type: nil }, model: user) }

        include_examples 'fails to complete verification for', attribute

        it { expect_validation_error_on(:type, :inclusion) }
      end

      context "when type is #{attribute}" do
        let(:verification) do
          Verification.new({ type: attribute, token: token }, model: user)
        end

        context 'when already verified' do
          let(:user)  { FactoryGirl.create(:"user_with_#{attribute}_verified") }
          let(:token) {}

          include_examples 'fails to complete verification for', attribute

          it { expect_validation_error_on(:base, :already_verified, base_options) }
        end

        context 'when verification token is invalid' do
          let(:token) {}

          include_examples 'fails to complete verification for', attribute

          it { expect_validation_error_on(:token, :invalid) }
        end

        context "when model has no #{attribute} verification token" do
          let(:user) do
            FactoryGirl.create(:user) do |u|
              u.send("#{attribute}=", nil)
            end
          end

          let(:token) { Faker::Internet.password  }

          include_examples 'fails to complete verification for', attribute

          it 'has an invalid error on token' do
            expect(verification.errors.added?(:token, :invalid)).to be_truthy
          end
        end

        context "when verification token doesn't match the model token" do
          let(:user)  { FactoryGirl.create(:"user_with_#{attribute}_verification") }
          let(:token) { Faker::Internet.password }

          include_examples 'fails to complete verification for', attribute

          it { expect_validation_error_on(:token, :invalid) }
        end

        context 'when verification token matches the model token' do
          let(:user)  { FactoryGirl.create(:"user_with_#{attribute}_verification") }
          let(:token) { user.send("#{attribute}_verification_token") }

          it { expect(completed).to be_truthy }

          it "verifies the model #{attribute}"  do
            expect(verification.model).to have_received(:"verify_#{attribute}!")
          end

          it 'has no error' do
            expect(verification.errors).to be_empty
          end

          context 'when verification token has expired' do
            let(:user) { FactoryGirl.create(:"user_with_#{attribute}_verification_expired") }

            include_examples 'fails to complete verification for', attribute

            it { expect_validation_error_on(:token, :invalid) }
          end
        end
      end
    end
  end

  def expect_validation_error_on(attribute, message, options = {})
    expect(verification.errors.added?(attribute, message, options)).to be_truthy
  end
end
