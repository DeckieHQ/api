require 'rails_helper'

RSpec.describe Verification, :type => :model do
  it do
    is_expected.to validate_inclusion_of(:type)
      .in_array(%w(email phone_number))
  end

  let(:user)         { FactoryGirl.create(:user) }
  let(:verification) { Verification.new({ type: 'email' }, user: user) }

  describe '#already_verified?' do
    it 'returns false' do
      expect(verification).to_not be_already_verified
    end

    context 'when invalid' do
      before do
        verification.type = nil
      end

      it 'returns false' do
        expect(verification).to_not be_already_verified
      end
    end

    context 'when user is waiting for verification' do
      before do
        user.generate_email_verification_token!
      end

      it 'returns false' do
        expect(verification).to_not be_already_verified
      end
    end

    context 'when user is already verified' do
      before do
        user.verify_email!
      end

      it 'returns true' do
        expect(verification).to be_already_verified
      end
    end
  end

  describe '#send_instructions' do
    context 'when invalid' do
      before do
        verification.type = nil
      end

      it 'returns false' do
        expect(verification.send_instructions).to be_falsy
      end

      it "doesn't generate an email verification token for the user" do
        expect(user).to_not receive(:generate_email_verification_token!)

        verification.send_instructions
      end

      it "doesn't send an email with verification instructions to the user" do
        expect(user).to_not receive(:send_email_verification_instructions)

        verification.send_instructions
      end

      it 'has errors' do
        verification.send_instructions

        expect(verification.errors).to_not be_empty
      end
    end

    context 'when valid' do
      it 'returns true' do
        expect(verification.send_instructions).to be_truthy
      end

      it 'generate an email verification token for the user' do
        expect(user).to receive(:generate_email_verification_token!)

        verification.send_instructions
      end

      it 'sends an email with verification instructions to the user' do
        expect(user).to receive(:send_email_verification_instructions)

        verification.send_instructions
      end

      it 'has no error' do
        verification.send_instructions

        expect(verification.errors).to be_empty
      end
    end
  end

  describe '#complete' do
    context 'when type is invalid' do
      before do
        verification.type = nil
      end

      # TODO: Move this to a shared example
      it 'returns false' do
        expect(verification.complete).to be_falsy
      end

      it "doesn't verify the user email" do
        expect(user).to_not receive(:verify_email!)

        verification.complete
      end

      it 'has errors' do
        verification.complete

        expect(verification.errors).to_not be_empty
      end
    end

    context 'when token is invalid' do
      # Token must be nil to test against a user without a verification token.
      before do
        verification.token = nil
      end

      it 'returns false' do
        expect(verification.complete).to be_falsy
      end

      it "doesn't verify the user email" do
        expect(user).to_not receive(:verify_email!)

        verification.complete
      end

      it 'has errors' do
        verification.complete

        expect(verification.errors).to_not be_empty
      end
    end

    context "when token doesn't match the user token" do
      before do
        user.generate_email_verification_token!

        verification.token = "#{user.email_verification_token}."
      end

      it 'returns false' do
        expect(verification.complete).to be_falsy
      end

      it "doesn't verify the user email" do
        expect(user).to_not receive(:verify_email!)

        verification.complete
      end

      it 'has errors' do
        verification.complete

        expect(verification.errors).to_not be_empty
      end
    end

    context 'when token matches the user token' do
      before do
        user.generate_email_verification_token!

        verification.token = user.email_verification_token
      end

      context 'when user token has expired' do
        before do
          user.update(email_verification_sent_at: Time.now - 6.hours)
        end

        it 'returns false' do
          expect(verification.complete).to be_falsy
        end

        it "doesn't verify the user email" do
          expect(user).to_not receive(:verify_email!)

          verification.complete
        end

        it 'has errors' do
          verification.complete

          expect(verification.errors).to_not be_empty
        end
      end

      it 'returns true' do
        expect(verification.complete).to be_truthy
      end

      it 'verifies the user email' do
        expect(user).to receive(:verify_email!)

        verification.complete
      end

      it 'has no error' do
        verification.complete

        expect(verification.errors).to be_empty
      end
    end
  end
end
