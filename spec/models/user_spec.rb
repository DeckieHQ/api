require 'rails_helper'

RSpec.describe User, :type => :model do
  [
    :email, :phone_number, :reset_password_token, :email_verification_token,
    :phone_number_verification_token
  ].each do |attribute|
    it { is_expected.to have_db_index(attribute).unique(true) }
  end

  it { is_expected.to have_one(:profile) }

  [
    :first_name,  :last_name, :birthday, :email, :password, :culture
  ].each do |attribute|
    it { is_expected.to validate_presence_of(attribute) }
  end

  it { is_expected.to validate_length_of(:first_name).is_at_most(64) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(64) }

  it { is_expected.to validate_plausible_phone(:phone_number) }

  it { is_expected.to validate_date_after(:birthday,  { limit: 100.year.ago }) }
  it { is_expected.to validate_date_before(:birthday, { limit: 18.year.ago + 1.day }) }

  it { is_expected.to validate_inclusion_of(:culture).in_array(%w(en)) }

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
      let(:profile) { user.profile }

      before do
        user.destroy
      end

      it 'unlinks its profile' do
        expect(profile.reload).to have_attributes({ user_id: nil })
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
