require 'rails_helper'

RSpec.describe Event, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:profile_id) }

    it { is_expected.to have_db_column(:short_description).of_type(:text) }

    it { is_expected.to have_db_column(:description).of_type(:text) }

    it do
      is_expected.to have_db_column(:capacity)
        .of_type(:integer).with_options(null: false)
    end

    [
      :submissions_count,      :attendees_count, :public_comments_count,
      :private_comments_count, :min_capacity
    ].each do |attribute|
      it do
        is_expected.to have_db_column(attribute)
          .of_type(:integer).with_options(null: false, default: 0)
      end
    end
  end

  describe 'Relationships' do
    it do
      is_expected.to belong_to(:host)
        .with_foreign_key('profile_id').counter_cache(:hosted_events_count)
    end

    it { is_expected.to include_deleted(:host) }

    it { is_expected.to have_many(:submissions).dependent(:destroy) }

    it { is_expected.to have_many(:comments).dependent(:destroy) }

    it do
      is_expected.to have_many(:confirmed_submissions)
        .conditions(status: :confirmed).class_name('Submission')
    end

    it do
      is_expected.to have_many(:pending_submissions)
        .conditions(status: :pending).class_name('Submission')
    end

    it do
      is_expected.to have_many(:attendees)
        .through(:confirmed_submissions).source(:profile)
    end

    it "attendees doesn't include deleted submissions" do
      event = FactoryGirl.create(:event_with_attendees)

      attendees_count = event.attendees.count

      event.confirmed_submissions.sample.destroy

      expect(event.attendees.count).to eq(attendees_count - 1)
    end

    it { is_expected.to have_many(:actions).dependent(:destroy) }

    it { is_expected.to have_many(:invitations).dependent(:destroy) }

  end

  describe 'Validations' do
    subject(:event) { FactoryGirl.create(:event) }

    it do
      is_expected.to have_many(:public_comments)
        .conditions(private: false).class_name('Comment')
    end

    [
      :title,  :category, :ambiance, :level, :capacity, :begin_at,
      :street, :postcode, :city, :country
    ].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end

    {
      category: %w(
        party board role-playing card dice miniature strategy cooperative video
        tile-based
      ),
      ambiance: %w(serious relaxed party),
      level: %w(beginner intermediate advanced expert)
    }.each do |attribute, values|
      it { is_expected.to validate_inclusion_of(attribute).in_array(values) }
    end

    it do
      is_expected.to validate_numericality_of(:capacity).only_integer
        .is_greater_than(0).is_less_than(1000)
    end

    it do
      is_expected.to validate_numericality_of(:min_capacity).only_integer
        .is_greater_than_or_equal_to(0)
    end

    context 'when event has attendees' do
      subject(:event) { FactoryGirl.create(:event_with_attendees) }

      it { is_expected.to_not allow_value(event.attendees_count - 1).for(:capacity) }

      it { is_expected.to allow_value(event.attendees_count).for(:capacity) }
    end

    it do
      is_expected.to validate_date_after(:begin_at, { limit: Time.now, on: :second })
    end

    it do
      is_expected.to validate_date_after(:end_at, { limit: :begin_at , on: :second })
    end

    context 'when event is closed' do
      subject(:event) { FactoryGirl.create(:event_closed) }

      it { is_expected.to be_valid }
    end

    it { is_expected.to_not allow_value(nil).for(:auto_accept) }

    {
      title:             128,
      short_description: 256,
      description:       8192,
      street:            128,
      postcode:          10,
      city:              64,
      state:             64,
      country:           64
    }.each do |attribute, length|
      it { is_expected.to validate_length_of(attribute).is_at_most(length) }
    end
  end

  context 'after create' do
    subject(:event) { FactoryGirl.create(:event) }

    it 'retrieves the event coordinates' do
      is_expected.to have_coordinates_of_address
    end
  end

  context 'after update' do
    subject(:event) { FactoryGirl.create(:event) }

    [:street, :postcode, :city, :state, :country].each do |field|
      context "with #{field}" do
        before do
          value = FactoryGirl.build(:event).send(field)

          event.update(field => value)

          GeoLocation.register(event)
        end

        it { is_expected.to have_coordinates_of_address }
      end
    end

    context 'with another attribute' do
      it "doesn't change its location" do
        expect { event.update(title: Faker::Hipster.sentence) }
          .not_to change { event.latitude }
      end
    end
  end

  it_behaves_like 'acts as paranoid'

  it_behaves_like 'an indexable resource'

  [:full, :closed].each do |state|
    method = "#{state}?"

    describe "##{method}" do
      subject(:method) { FactoryGirl.create(:event).send(method) }

      it { is_expected.to be_falsy }

      context "when event is #{state}" do
        subject(:method) { FactoryGirl.create(:"event_#{state}").send(method) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '.member?' do
    let(:event) { FactoryGirl.create(:event_with_attendees) }

    context 'when user is member of the event' do
      let(:profile) { FactoryGirl.create(:profile) }

      it { expect(event.member?(profile)).to be_falsy }
    end

    context 'when user is member of the event' do
      let(:profile) { event.attendees.last }

      it { expect(event.member?(profile)).to be_truthy }
    end
  end

  describe '.submission_of' do
    let(:event) { FactoryGirl.create(:event_with_submissions) }

    context 'when there is no user' do
      it { expect(event.submission_of()).to be_nil }
    end

    context "when user hasn't a submission on the event" do
      let(:user) { FactoryGirl.create(:user) }

      it { expect(event.submission_of(user)).to be_nil }
    end

    context 'when user has a submission on the event' do
      let(:submission) { event.submissions.last }
      let(:user)       { submission.profile.user }

      it { expect(event.submission_of(user).to_json).to eq(submission.to_json) }
    end
  end

  describe '#max_confirmable_submissions' do
    let(:event) do
      FactoryGirl.create(:event_with_submissions, :with_pending_submissions)
    end

    it 'returns the possible confirmable submissions' do
      expect(event.max_confirmable_submissions).to eq(
        event.pending_submissions.take(event.capacity - event.attendees_count)
      )
    end
  end

  describe '#switched_to_auto_accept?' do
    subject { event.switched_to_auto_accept? }

    let(:event) { FactoryGirl.create(:event) }

    it { is_expected.to be_falsy }

    context 'after switching to auto_accept' do
      before do
        event.update(auto_accept: true)
      end

      it { is_expected.to be_truthy }
    end

    context 'after switching to manual_accept' do
      let(:event) do
        FactoryGirl.create(:event, :auto_accept)
      end

      before do
        event.update(auto_accept: false)
      end

      it { is_expected.to be_falsy }
    end
  end

  describe '#receivers_ids_for' do
    let(:event) do
      FactoryGirl.create(:event_with_attendees, :with_pending_submissions)
    end

    subject(:receivers_ids_for) { event.receivers_ids_for(action) }

    %w(submit unsubmit).each do |type|
      context "with a #{type} action" do
        let(:action) { double(type: type) }

        it 'returns only the event host id' do
          is_expected.to eq([event.host.id])
        end
      end
    end

    %w(cancel).each do |type|
      context "with a #{type} action" do
        let(:action) { double(type: type) }

        it 'returns the event submissions profiles ids + host ids' do
          is_expected.to eq(event.submissions.pluck('profile_id'))
        end
      end
    end

    %w(join ready not_ready).each do |type|
      context "with a #{type} action" do
        let(:action) { double(type: type) }

        it 'returns the event attendees ids' do
          is_expected.to eq(event.attendees.pluck('id').push(event.host.id))
        end
      end
    end

    %w(update leave comment).each do |type|
      context "with a #{type} action" do
        let(:action) { double(type: type, actor: event.host) }

        it 'returns the event attendees + host ids' do
          expected_profiles = event.attendees.pluck('id').push(event.host.id)

          expected_profiles.delete(action.actor.id)

          is_expected.to eq(expected_profiles)
        end
      end
    end

    %w(remove_full remove_start).each do |type|
      context "with a #{type} action" do
        let(:action) { double(type: type) }

        it 'returns the pending submissions profile ids' do
          is_expected.to eq(event.pending_submissions.pluck('profile_id'))
        end
      end
    end

    context 'with unsupported type' do
      it 'raises an error' do
        expect { receivers_ids_for }.to raise_error
      end
    end
  end

  describe '#ready?' do

    context 'when attendees_count is greater than or equal to min_capacity' do
      subject(:event) { FactoryGirl.create(:event_with_attendees, :ready) }

      it { is_expected.to be_ready }
    end

    context 'when attendees_count is less than min_capacity' do
      subject(:event) { FactoryGirl.create(:event_with_attendees, :not_ready) }

      it { is_expected.to_not be_ready }
    end
  end

  describe '.opened' do
    let(:events) { Event.all.opened }

    before do
      FactoryGirl.create_list(:event,        Faker::Number.between(1, 4))
      FactoryGirl.create_list(:event_closed, Faker::Number.between(1, 4))
    end

    it 'returns the opened events' do
      expect_opened_events(true)
    end

    ['true', true, 1].each do |value|
      context "when parameter equals #{value}" do
        let(:events) { Event.all.opened(value) }

        it 'returns the opened events' do
          expect_opened_events(true)
        end
      end
    end

    ['false', false, 0, 'whatever', { is_a: :hash }].each do |value|
      context "when parameter equals #{value}" do
        let(:events) { Event.all.opened(value) }

        it 'returns the closed events' do
          expect_opened_events(false)
        end
      end
    end

    def expect_opened_events(opened)
      results = events.pluck(:begin_at).keep_if do |begin_at|
        opened ? begin_at > Time.now : begin_at <= Time.now
      end
      expect(results).to_not be_empty
    end
  end

  describe '.with_pending_submissions' do
    let!(:events) do
      FactoryGirl.create_list(:event_with_submissions, 5)
    end

    before do
      FactoryGirl.create_list(:event, 5)
    end

    it 'returns the event with submissions' do
      expect(Event.with_pending_submissions).to have_records(
        Event.joins(:submissions).where({ submissions: { status: :pending } }).distinct
      )
    end
  end
end
