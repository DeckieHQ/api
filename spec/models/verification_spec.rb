require 'rails_helper'

RSpec.describe Verification, :type => :model do
  it do
    is_expected.to validate_inclusion_of(:type)
      .in_array(%w(email phone_number))
  end

  let(:user) { FactoryGirl.create(:user_with_phone_number) }

  before do
    SMSDeliveries.use_fake_provider
  end

  after do
    MailDeliveries.clear
    SMSDeliveries.clear
  end

  [:email, :phone_number].each do |attribute|
    let(:base_options) { { type: verification.type, target: :User } }

    describe '#send_instructions' do
      context 'when type is invalid' do
        let(:verification) { Verification.new({ type: nil }, model: user) }

        before do
          verification.type = nil
        end

        include_examples 'fails to send verification for', attribute

        it 'has an inclusion error on type' do
          verification.send_instructions

          expect(verification.errors.added?(:type, :inclusion)).to be_truthy
        end
      end

      context "when type is #{attribute}" do
        let(:verification) { Verification.new({ type: attribute }, model: user) }

        context 'when model has no attribute to verify' do
          before do
            user.send("#{attribute}=", nil)
          end

          include_examples 'fails to send verification for', attribute

          it "has a #{attribute} unspecified error on base" do
            verification.send_instructions

            expect(
              verification.errors.added?(:base, :unspecified, base_options)
            ).to be_truthy
          end
        end

        context "when #{attribute} is already verified" do
          let(:user) { FactoryGirl.create(:"user_with_#{attribute}_verified") }

          include_examples 'fails to send verification for', attribute

          it "has a #{attribute} already verified error on base" do
            verification.send_instructions

            expect(
              verification.errors.added?(:base, :already_verified, base_options)
            ).to be_truthy
          end
        end

        context 'when everything is valid' do
          it 'returns true' do
            expect(verification.send_instructions).to be_truthy
          end

          it "generate an #{attribute} verification token for the model" do
            expect(verification.model).to receive(:"generate_#{attribute}_verification_token!")

            verification.send_instructions
          end

          it "sends a message with verification instructions to the model #{attribute}" do
            expect(verification.model).to receive(:"send_#{attribute}_verification_instructions")

            verification.send_instructions
          end

          it 'has no error' do
            verification.send_instructions

            expect(verification.errors).to be_empty
          end

          if attribute == :phone_number
            context "when #{attribute} is unassigned" do
              before do
                SMSDeliveries.use_fake_provider(status: 400)
              end

              it 'returns false' do
                expect(verification.send_instructions).to be_falsy
              end

              it "has a #{attribute} unassigned error on base" do
                verification.send_instructions

                expect(
                  verification.errors.added?(:base, :unassigned, base_options)
                ).to be_truthy
              end
            end
          end
        end
      end
    end

    describe '#complete' do
      context 'when type is invalid' do
        let(:verification) { Verification.new({ type: nil }, model: user) }

        include_examples 'fails to complete verification for', attribute

        it 'has an inclusion error on type' do
          verification.complete

          expect(verification.errors.added?(:type, :inclusion)).to be_truthy
        end
      end

      context "when type is #{attribute}" do
        let(:verification) { Verification.new({ type: attribute }, model: user) }

        context 'when already verified' do
          let(:user) { FactoryGirl.create(:"user_with_#{attribute}_verified") }

          include_examples 'fails to complete verification for', attribute

          it "has a #{attribute} already verified error on base" do
            verification.complete

            expect(
              verification.errors.added?(:base, :already_verified, base_options)
            ).to be_truthy
          end
        end

        context 'when verification token is invalid' do
          before do
            verification.token = nil
          end

          include_examples 'fails to complete verification for', attribute

          it 'has an invalid error on token' do
            verification.complete

            expect(verification.errors.added?(:token, :invalid)).to be_truthy
          end
        end

        context "when model has no #{attribute} verification token" do
          let(:user) { FactoryGirl.create(:user) }

          before do
            verification.token = Faker::Internet.password
          end

          include_examples 'fails to complete verification for', attribute

          it 'has an invalid error on token' do
            verification.complete

            expect(verification.errors.added?(:token, :invalid)).to be_truthy
          end
        end

        context "when verification token doesn't match the model token" do
          let(:user) { FactoryGirl.create(:"user_with_#{attribute}_verification") }

          before do
            model_token = user.send("#{attribute}_verification_token")

            verification.token = "#{model_token}."
          end

          include_examples 'fails to complete verification for', attribute

          it 'has an invalid error on token' do
            verification.complete

            expect(verification.errors.added?(:token, :invalid)).to be_truthy
          end
        end

        context 'when verification token matches the model token' do
          let(:user) { FactoryGirl.create(:"user_with_#{attribute}_verification") }

          before do
            model_token = user.send("#{attribute}_verification_token")

            verification.token = model_token
          end

          it 'returns true' do
            expect(verification.complete).to be_truthy
          end

          it "verifies the model #{attribute}"  do
            expect(verification.model).to receive(:"verify_#{attribute}!")

            verification.complete
          end

          it 'has no error' do
            verification.complete

            expect(verification.errors).to be_empty
          end

          context 'when verification token has expired' do
            let(:user) { FactoryGirl.create(:"user_with_#{attribute}_verification_expired") }

            include_examples 'fails to complete verification for', attribute

            it 'has an invalid error on token' do
              verification.complete

              expect(verification.errors.added?(:token, :invalid)).to be_truthy
            end
          end
        end
      end
    end
  end
end
