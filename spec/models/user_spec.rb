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
      is_expected.to have_db_column(:preferences)
        .of_type(:jsonb).with_options(null: false, default: {})
    end

    it do
      is_expected.to have_db_column(:notifications_count)
        .of_type(:integer).with_options(null: false, default: 0)
    end
  end

  describe 'Validations' do
    subject { FactoryGirl.build(:user_with_phone_number) }

    [
      :first_name,  :last_name, :birthday, :email, :password, :culture
    ].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end

    it do
      is_expected.to validate_uniqueness_of(:email).case_insensitive
    end

    it { is_expected.to validate_length_of(:first_name).is_at_most(64) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(64) }

    it { is_expected.to validate_plausible_phone(:phone_number) }

    it { is_expected.to validate_date_after(:birthday,  { limit: 100.year.ago }) }
    it { is_expected.to validate_date_before(:birthday, { limit: 18.year.ago + 1.day }) }

    it { is_expected.to validate_inclusion_of(:culture).in_array(%w(en fr)) }
  end

  describe 'Relationships' do
    it { is_expected.to have_one(:profile).dependent(:destroy) }

    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  context 'after create' do
    subject(:user) { FactoryGirl.create(:user) }

    it 'has an authentication token' do
      expect(user.authentication_token).to be_valid_token :secure
    end

    it 'has a profile' do
      expect_profile_propagation
    end

    it 'delegates its profile hosted_events' do
      expect(user.hosted_events).to eq(user.profile.hosted_events)
    end

    it 'delegates its profile invitations' do
      expect(user.invitations).to eq(user.profile.invitations)
    end

    it 'is not verified' do
      expect(user).not_to be_verified
    end

    it 'has subscribed to all notifications' do
      expect(user.preferences['notifications']).to eq(Notification.types)
    end
  end

  context 'after update' do
    subject(:user) { FactoryGirl.create(:user) }

    let(:user_update) { FactoryGirl.build([:user, :user_verified].sample) }

    [
      :first_name, :last_name, :email_verified_at, :phone_number_verified_at
    ].each do |attribute|
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
      display_name: "#{user.first_name} #{user.last_name.capitalize[0]}",
      email_verified:        user.email_verified?,
      phone_number_verified: user.phone_number_verified?
    })
  end

  it_behaves_like 'acts as paranoid'

  it_behaves_like 'acts as verifiable', :email,
    carrier: UserMailer,
    faker: -> { Faker::Internet.email },
    token_type: :friendly

  it_behaves_like 'acts as verifiable', :phone_number,
    carrier: UserSMSer,
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

    it 'returns the user profile opened hosted events' do
      is_expected.to eq(user.profile.opened_hosted_events)
    end
  end

  describe '#opened_submissions' do
    let(:user) { FactoryGirl.create(:user, :with_submissions) }

    subject { user.opened_submissions }

    it 'returns the user submissions to opened events' do
      is_expected.to eq(user.submissions.filter({ event: :opened }))
    end
  end

  describe '#reset_notifications_count!' do
    let(:user) do
      FactoryGirl.create(:user, notifications_count: Faker::Number.between(1, 5))
    end

    it 'sets the notifications_count to 0' do
      expect { user.reset_notifications_count! }.to change { user.notifications_count }.to(0)
    end
  end

  describe '#subscribed_to?' do
    let(:notification) { FactoryGirl.create(:notification) }

    let(:user) { FactoryGirl.create(:user) }

    subject { user.subscribed_to?(notification) }

    context 'when user subscribed to the notification' do
      before do
        user.update(preferences: { notifications: [notification.type] })
      end

      it { is_expected.to be_truthy }
    end

    context "when user doesn't subscribed to the notification" do

      before do
        user.update(preferences: { notifications: [] })
      end

      it { is_expected.to be_falsy }
    end
  end

  describe '#host_of?' do
    let(:host) { FactoryGirl.create(:user_with_hosted_events) }

    let(:user) { FactoryGirl.create(:user) }

    subject(:host_of?) { host.host_of?(user) }

    it { is_expected.to be_falsy }

    context 'when user is an attendee of at least of event of the host' do
      before do
        event = host.hosted_events.sample

        event.update(auto_accept: true)

        JoinEvent.new(user.profile, event).call
      end

      it { is_expected.to be_truthy }
    end
  end
end
