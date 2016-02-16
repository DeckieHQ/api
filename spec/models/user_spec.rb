require 'rails_helper'

RSpec.describe User, :type => :model do
  # Database
  [
    :email, :phone_number, :reset_password_token, :email_verification_token,
    :phone_number_verification_token
  ].each do |attribute|
    it { is_expected.to have_db_index(attribute).unique(true) }
  end

  # Relations
  it { is_expected.to have_one(:profile) }

  # Validations
  [
    :first_name,  :last_name, :birthday, :email, :password, :culture
  ].each do |attribute|
    it { is_expected.to validate_presence_of(attribute) }
  end

  it { is_expected.to validate_length_of(:first_name).is_at_most(64) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(64) }

  it { is_expected.to validate_plausible_phone(:phone_number) }

  it { is_expected.to validate_date_after(:birthday,  100.year.ago) }
  it { is_expected.to validate_date_before(:birthday,  18.year.ago + 1.day) }

  it { is_expected.to validate_inclusion_of(:culture).in_array(%w(en)) }

  context 'when created' do
    subject(:user) { FactoryGirl.create(:user) }

    it 'has an authentication token' do
      expect(user.authentication_token).to be_valid_token :secure
    end

    it 'has a profile' do
      expect(user.profile).to be_present
    end

    context 'when destroyed' do
      before do
        @profile = user.profile

        user.destroy

        @profile.reload
      end

      it 'unlinks its profile' do
        expect(@profile.user_id).to be_nil
      end
    end
  end

  include_examples 'acts as verifiable', :email,
    deliveries: MailDeliveries,
    faker: -> { Faker::Internet.email },
    token_type: :friendly

  include_examples 'acts as verifiable', :phone_number,
    deliveries: SMSDeliveries,
    faker: -> { Faker::PhoneNumber.plausible },
    token_type: :pin
end
