require 'rails_helper'

RSpec.describe User, :type => :model do
  describe 'Database' do
    [
      :email, :reset_password_token, :email_verification_token,
      :phone_number_verification_token
    ].each do |attribute|
      it { is_expected.to have_db_index(attribute).unique(true) }
    end

    it do
      is_expected.to have_db_column(:subscriptions)
        .of_type(:text).with_options(array: true, default: [])
    end
  end

  describe 'Validations' do
    subject { FactoryGirl.build(:user_with_phone_number) }

    it { is_expected.to have_one(:profile).dependent(:nullify) }

    it { is_expected.to have_many(:notifications).dependent(:destroy) }

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


    it { is_expected.to allow_value(%w(event-update)).for(:subscriptions) }

    it { is_expected.to_not allow_value(%w(unsupported)).for(:subscriptions) }
  end

  describe 'beforeValidation' do
    subject(:user) { FactoryGirl.build(:user, subscriptions: subscriptions) }

    before { user.valid? }

    context 'when subscriptions is nil' do
      let(:subscriptions) {}

      it 'replaces subscriptions by an empty array' do
        expect(user.subscriptions).to eq([])
      end
    end

    context 'when subscriptions has duplicates' do
      let(:subscriptions) { %w(event-update event-update event-subscribe) }

      it 'removes the duplicates' do
        expect(user.subscriptions).to eq(subscriptions.uniq)
      end
    end
  end

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

    it 'has a shortcut to its profile hosted_events' do
      expect(user.hosted_events).to eq(user.profile.hosted_events)
    end

    it 'is not verified' do
      expect(user).not_to be_verified
    end
  end

  include_examples 'acts as verifiable', :email,
    deliveries: MailDeliveries,
    faker: -> { Faker::Internet.email },
    token_type: :friendly

  include_examples 'acts as verifiable', :phone_number,
    deliveries: SMSDeliveries,
    faker: -> { Fake::PhoneNumber.plausible },
    token_type: :pin

  describe '#verified?' do
    subject(:verified?) { user.verified? }

    before { verified? }

    [:email, :phone_number].each do |attribute|
      context "when user #{attribute} is not verified" do
        let(:user) { FactoryGirl.create(:"user_with_#{attribute}_verified") }

        it { is_expected.to be_falsy }
      end
    end

    context 'when user is verified' do
      let(:user) { FactoryGirl.create(:user_verified) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#opened_hosted_events' do
    let(:user) { FactoryGirl.create(:user_with_hosted_events) }

    subject { user.opened_hosted_events }

    it 'returns the user opened hosted events' do
      is_expected.to eq(user.hosted_events.opened)
    end
  end

  describe '#opened_submissions' do
    let(:user) { FactoryGirl.create(:user, :with_submissions) }

    subject { user.opened_submissions }

    it 'returns the user submissions to opened events' do
      is_expected.to eq(user.submissions.filter({ event: :opened }))
    end
  end
end
