require 'rails_helper'

RSpec.describe User, :type => :model do
  # Database
  it { is_expected.to have_db_index(:email).unique(true) }
  it { is_expected.to have_db_index(:phone_number).unique(true) }
  it { is_expected.to have_db_index(:reset_password_token).unique(true) }
  it { is_expected.to have_db_index(:email_verification_token).unique(true) }
  it { is_expected.to have_db_index(:phone_number_verification_token).unique(true) }

  # Relations
  it { is_expected.to have_one(:profile) }

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

    it 'has a profile' do
      expect_profile_propagation
    end

    context 'when updated' do
      let(:user_update) { FactoryGirl.build(:user) }

      [:first_name, :last_name].each do |attribute|
        context "with #{attribute}" do
          before do
            user.update(attribute => user_update.send(attribute))
          end

          it 'updates its profile' do
            expect_profile_propagation
          end
        end
      end
    end

    def expect_profile_propagation
      expect(user.profile).to have_attributes({
        display_name: "#{user.first_name} #{user.last_name.capitalize[0]}"
      })
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
