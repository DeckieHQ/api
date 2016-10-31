require 'rails_helper'

RSpec.describe Event, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:profile_id) }

    it { is_expected.to have_db_index(:event_id) }

    it { is_expected.to have_db_column(:short_description).of_type(:text) }

    it { is_expected.to have_db_column(:description).of_type(:text) }

    it do
      is_expected.to have_db_column(:capacity)
        .of_type(:integer).with_options(null: true, default: nil)
    end

    [:auto_accept, :private, :unlimited_capacity].each do |attribute|
      it do
        is_expected.to have_db_column(attribute)
          .of_type(:boolean).with_options(null: false, default: false)
      end
    end

    it do
      is_expected.to have_db_column(:type).of_type(:integer)
        .with_options(null: false, default: :normal)
    end

    [
      :submissions_count,      :attendees_count, :public_comments_count,
      :private_comments_count, :children_count, :min_capacity
    ].each do |attribute|
      it do
        is_expected.to have_db_column(attribute)
          .of_type(:integer).with_options(null: false, default: 0)
      end
    end

    it do
      is_expected.to have_db_column(:begin_at_range)
        .of_type(:jsonb).with_options(null: false, default: {})
    end
  end

  describe 'Relationships' do
    it do
      is_expected.to belong_to(:host).class_name('Profile')
        .with_foreign_key('profile_id').counter_cache(:hosted_events_count)
    end

    it do
      is_expected.to belong_to(:parent).class_name('Event')
        .with_foreign_key('event_id').counter_cache(:children_count)
    end

    it { is_expected.to include_deleted(:host) }

    context 'with child events' do
      subject { FactoryGirl.create_list(:event, 3, :of_recurrent) }

      it { is_expected.to include_deleted(:parent) }
    end

    it { is_expected.to have_many(:children).class_name('Event') }

    it { is_expected.to have_many(:submissions).dependent(:destroy) }

    it { is_expected.to have_many(:comments).dependent(:destroy) }

    it { is_expected.to have_many(:time_slots).dependent(:destroy) }

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

    it do
      is_expected.to have_many(:public_comments)
        .conditions(private: false).class_name('Comment')
    end
  end

  describe 'Validations' do
    subject(:event) { FactoryGirl.create(:event) }

    [
      :title,  :category, :ambiance, :level, :capacity, :begin_at,
      :street, :postcode, :city, :country
    ].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end

    {
      category: %w(
        board role-playing card deck-building dice miniature video outdoor
        strategy cooperative ambiance playful tile-based, other
      ),
      ambiance: %w(relaxed serious teasing),
      level: %w(beginner intermediate advanced),
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

    [:auto_accept, :private, :unlimited_capacity].each do |attribute|
      it { is_expected.to_not allow_value(nil).for(attribute) }
    end

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

    context 'when event is flexible' do
      subject(:event) { FactoryGirl.create(:event, :flexible) }

      it { is_expected.to validate_absence_of(:begin_at) }

      it { is_expected.to validate_absence_of(:end_at) }

      [
        nil, 'lol', [], [Time.now + 2.days], [Time.now + 2.days, nil], [Time.now + 2.days, 2.days.ago]
      ].each do |value|
        it { is_expected.to_not allow_value(value).for(:new_time_slots).on(:create) }
      end
    end

    context 'when event is recurrent' do
      subject(:event) { FactoryGirl.create(:event, :recurrent) }

      it { is_expected.to validate_absence_of(:begin_at) }

      it { is_expected.to validate_absence_of(:end_at) }

      [
        nil, 'lol', [], [Time.now + 2.days], [Time.now + 2.days, nil], [Time.now + 2.days, 2.days.ago]
      ].each do |value|
        it { is_expected.to_not allow_value(value).for(:new_time_slots).on(:create) }
      end
    end

    context 'when event has unlimited capacity' do
      subject(:event) { FactoryGirl.create(:event, :unlimited_access) }

      it { is_expected.to validate_absence_of(:capacity) }
    end
  end

  context 'after create' do
    subject(:event) { FactoryGirl.create(:event) }

    it 'retrieves the event coordinates' do
      is_expected.to have_coordinates_of_address
    end

    it 'has no time slots' do
      expect(event.time_slots).to be_empty
    end

    context 'when event is flexible' do
      subject(:event) { FactoryGirl.create(:event, :flexible) }

      it 'creates a time slot for each new_time_slots datetime' do
        expect(
          event.time_slots.where(begin_at: event.new_time_slots)
        ).to_not be_empty
      end

      it 'assigns begin_at_range' do
        expect(event.begin_at_range).to eq(
          { min: event.new_time_slots.min, max: event.new_time_slots.max }.as_json
        )
      end
    end

    context 'when event is recurrent' do
      subject(:event) { FactoryGirl.create(:event, :recurrent) }

      it 'creates a normal event child for each new_time_slots datetime' do
        expect(
          event.children.where(
            begin_at: event.new_time_slots, type: :normal, children_count: 0
          )
        ).to_not be_empty
      end

      it 'assigns event attributes for each children' do
        event.children.each do |child|
          expect(propagation_attributes_for(child)).to eq(propagation_attributes_for(event))
        end
      end

      def propagation_attributes_for(record)
        record
        .attributes
        .except('id')
        .except('type')
        .except('event_id')
        .except('children_count')
        .except('created_at')
        .except('updated_at')
        .except('begin_at')
        .except('latitude')
        .except('longitude')
      end
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

  [:full, :closed, :reached_time_slot_min].each do |state|
    method = "#{state}?"

    describe "##{method}" do
      subject(:method) { FactoryGirl.create(:event).send(method) }

      it { is_expected.to be_falsy }

      context "when event is #{state}" do
        subject(:method) { FactoryGirl.create(:"event_#{state}").send(method) }

        it { is_expected.to be_truthy }

        if state == :full
          context 'when event has unlimited capacity' do
            subject(:method) do
              FactoryGirl.create(:event, :unlimited_access).full?
            end

            it { is_expected.to be_falsy }
          end
        end
      end

      [:flexible, :recurrent].each do |type|
        context "when event is #{type}" do
          subject(:method) { FactoryGirl.create(:event, type).send(method) }

          it { is_expected.to be_falsy }
        end
      end
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

  describe '#top_resource' do
    let(:event) { FactoryGirl.create(:event) }

    subject { event.top_resource }

    it { is_expected.to eq(event) }
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

        it 'returns the event submissions profiles ids' do
          is_expected.to eq(event.submissions.pluck('profile_id'))
        end


        context 'when event is flexible' do
          let(:event) { FactoryGirl.create(:event_with_time_slots_members) }

          it 'returns the event time slots members ids' do
            is_expected.to eq(event.time_slots_members.pluck('id'))
          end
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

  describe '#ready?, #just_ready?' do
    context 'when attendees_count is greater than min_capacity' do
      subject(:event) { FactoryGirl.create(:event_with_attendees, :ready) }

      it { is_expected.to be_ready }

      it { is_expected.to_not be_just_ready }
    end

    context 'when attendees_count is equal to min_capacity' do
      subject(:event) { FactoryGirl.create(:event_with_attendees, :just_ready) }

      it { is_expected.to be_ready }

      it { is_expected.to be_just_ready }
    end

    context 'when attendees_count is less than min_capacity' do
      subject(:event) { FactoryGirl.create(:event_with_attendees, :not_ready) }

      it { is_expected.to_not be_ready }

      it { is_expected.to_not be_just_ready }
    end
  end

  describe '#optimum_time_slot' do
    let(:event) { FactoryGirl.create(:event_with_time_slots_members) }

    subject(:optimum_time_slot) { event.optimum_time_slot }

    it do
      is_expected.to eq(
        event.time_slots.order('begin_at ASC').max_by(&:members_count)
      )
    end
  end

  describe '#time_slots_members' do
    let(:event) { FactoryGirl.create(:event_with_time_slots_members) }

    subject(:time_slots_members) { event.time_slots_members }

    it { is_expected.to_not be_empty }

    it do
      expect(time_slots_members.pluck('id')).to match_array(
        TimeSlotSubmission.where(time_slot_id: event.time_slots.pluck('id')).pluck('profile_id').uniq
      )
    end
  end

  describe '.confirmable_in' do
    [10, 40, 60].each do |percents|
      context "with #{percents}%" do
        subject { Event.confirmable_in(percentage: percents) }

        let!(:confirmable) { FactoryGirl.create(:event_confirmable) }

        before { FactoryGirl.create_list(:event, 5, :flexible) }

        it "is equal to flexible events confirmables under #{percents}%" do
          is_expected.to eq([confirmable])
        end
      end
    end
  end

  describe '.opened' do
    let(:events) { Event.all.opened }

    before do
      FactoryGirl.create_list(:event,        Faker::Number.between(1, 4))
      FactoryGirl.create_list(:event_closed, Faker::Number.between(1, 4))
      FactoryGirl.create_list(:event,        Faker::Number.between(1, 4), :flexible)
      FactoryGirl.create_list(:event,        Faker::Number.between(1, 4), :recurrent)
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

        it 'includes flexible events' do
          expect(events.flexible).to_not be_empty
        end

        it 'includes recurrent events' do
          expect(events.recurrent).to_not be_empty
        end
      end
    end

    ['false', false, 0, 'whatever', { is_a: :hash }].each do |value|
      context "when parameter equals #{value}" do
        let(:events) { Event.all.opened(value) }

        it 'returns the closed events' do
          expect_opened_events(false)
        end

        it "doesn't include flexible events" do
          expect(events.flexible).to be_empty
        end
      end
    end

    def expect_opened_events(opened)
      results = events.normal.pluck(:begin_at).keep_if do |begin_at|
        opened ? begin_at > Time.now : begin_at <= Time.now
      end
      expect(results).to_not be_empty
    end
  end

  describe '.type' do
    let(:type) { Event.types.keys.sample }
    before do
      FactoryGirl.create_list(:event, Faker::Number.between(1, 4))
      FactoryGirl.create_list(:event, Faker::Number.between(1, 4), :flexible)
      FactoryGirl.create_list(:event, Faker::Number.between(1, 4), :recurrent)
    end

    it 'returns events with specified type' do
      expect(Event.type(type).pluck(:type)).to all( eq(type) )
    end
  end

  describe '.not_type' do
    let(:type) { Event.types.keys.sample }

    before do
      FactoryGirl.create_list(:event, Faker::Number.between(1, 4))
      FactoryGirl.create_list(:event, Faker::Number.between(1, 4), :flexible)
      FactoryGirl.create_list(:event, Faker::Number.between(1, 4), :recurrent)
    end

    it 'returns all events excepts ones with specified type' do
      expect(Event.not_type(type).pluck(:type)).to_not include(type)
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
end
