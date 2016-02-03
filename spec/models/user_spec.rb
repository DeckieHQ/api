require 'rails_helper'

RSpec.describe User, :type => :model do
  # Database
  it { is_expected.to have_db_index(:email).unique(true) }
  it { is_expected.to have_db_index(:phone_number).unique(true) }
  it { is_expected.to have_db_index(:reset_password_token).unique(true) }
  it { is_expected.to have_db_index(:email_verification_token).unique(true) }
  it { is_expected.to have_db_index(:phone_number_verification_token).unique(true) }

  # Validations
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_length_of(:first_name).is_at_most(64) }

  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(64) }

  it { is_expected.to validate_presence_of(:birthday) }

  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to validate_presence_of(:password) }

  it { is_expected.to validate_plausible_phone(:phone_number) }

  it { is_expected.to validate_date_after(:birthday,  100.year.ago) }
  it { is_expected.to validate_date_before(:birthday,  18.year.ago + 1.day) }

  context 'when created' do
    subject(:user) { FactoryGirl.create(:user) }

    it 'has an authentication token' do
      expect(user.authentication_token).to be_valid_token :secure
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
