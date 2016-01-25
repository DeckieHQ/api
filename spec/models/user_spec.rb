require 'rails_helper'

RSpec.describe User, :type => :model do
  # Database
  it { is_expected.to have_db_index(:email).unique(true) }
  it { is_expected.to have_db_index(:phone_number).unique(true) }
  it { is_expected.to have_db_index(:reset_password_token).unique(true) }
  it { is_expected.to have_db_index(:email_verification_token).unique(true) }

  # Validations
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_length_of(:first_name).is_at_most(64) }

  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(64) }

  it { is_expected.to validate_presence_of(:birthday) }

  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to validate_presence_of(:password) }

  it { is_expected.to validate_plausible_phone(:phone_number) }

  it { is_expected.to validate_date_after(:birthday, 100.year, :ago) }
  it { is_expected.to validate_date_before(:birthday, 18.year - 1.day, :ago) }

  context 'when created' do
    subject(:user) { FactoryGirl.create(:user) }

    it 'has an authentication token' do
      expect(user.authentication_token).to be_present
    end

    it 'has an unverified email' do
      expect(user).to have_unverified :email
    end
  end

  context 'updating the email' do
    before do
      user.update(email: 'updating.email@yopmail.com')
    end

    context 'when user is verified' do
      subject(:user) { FactoryGirl.create(:user).tap(&:verify_email!) }

      it 'reset the email verification' do
        expect(user).to have_unverified :email
      end
    end

    context 'when user email is waiting for verification' do
      subject(:user) do
        FactoryGirl.create(:user).tap(&:generate_email_verification_token!)
      end

      it 'reset the email verification' do
        expect(user).to have_unverified :email
      end
    end
  end

  context 'updating another attribute' do
    subject(:user) do
      FactoryGirl.create(:user).tap(&:generate_email_verification_token!)
    end

    before do
      @previous_attributes = user.attributes.except('first_name', 'updated_at')

      user.update(first_name: 'Updating')
    end

    it "doesn't reset the email verification" do
      expect(user).to have_attributes(@previous_attributes)
    end
  end

  describe '#generate_email_verification_token!' do
    subject(:user) { FactoryGirl.create(:user) }

    before do
      user.generate_email_verification_token!
      user.reload
    end

    it 'add to the user an email verification token' do
      expect(user.email_verification_token).to be_present
    end

    it 'set the user email_verification_sent_at to current datetime' do
      expect(user.email_verification_sent_at).to equal_time(Time.now)
    end
  end

  describe '#verify_email!' do
    subject(:user) { FactoryGirl.create(:user) }

    before do
      user.generate_email_verification_token!
      user.verify_email!
      user.reload
    end

    it 'removes the user email verification token' do
      expect(user.email_verification_token).to be_nil
    end

    it 'set the user email_verified_at to current datetime' do
      expect(user.email_verified_at).to equal_time(Time.now)
    end
  end

  describe '#send_email_verification_instructions' do
    subject(:user) { FactoryGirl.create(:user) }

    before do
      user.generate_email_verification_token!
    end

    it 'sends an email with verification instructions' do
      expect {
        user.send_email_verification_instructions
      }.to change { MailDeliveries.count }.by(1)
    end
  end
end
