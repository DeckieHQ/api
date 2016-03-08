require 'rails_helper'

RSpec.describe Event, :type => :model do
  describe 'Validations' do
    it { is_expected.to have_db_index(:profile_id) }

    it { is_expected.to belong_to(:host) }

    it { is_expected.to have_many(:subscriptions) }
    it { is_expected.to have_many(:attendees) }

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
      is_expected.to validate_numericality_of(:capacity)
        .is_greater_than(0)
        .is_less_than(1000)
    end

    it do
      is_expected.to validate_date_after(:begin_at, { limit: Time.now, on: :second })
    end

    it do
      is_expected.to validate_date_after(:end_at, { limit: :begin_at , on: :second })
    end

    {
      title:       128,
      description: 8192,
      street:      128,
      postcode:    10,
      city:        64,
      state:       64,
      country:     64
    }.each do |attribute, length|
      it { is_expected.to validate_length_of(attribute).is_at_most(length) }
    end
  end

  context 'when created' do
    subject(:event) { FactoryGirl.create(:event) }

    it 'retrieves the event coordinates' do
      is_expected.to have_coordinates_of_address
    end
  end

  context 'when updated' do
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

  context 'when destroyed' do
    subject(:event) { FactoryGirl.create(:event_with_attendees) }

    before do
      event.destroy
    end

    it 'removes its attendees' do
      expect(event.attendees).to be_empty
    end
  end

  describe '#closed?' do
    subject(:event) { FactoryGirl.create(:event) }

    let(:closed?) { event.closed? }

    before do
      closed?
    end

    it { expect(closed?).to be_falsy }

    it 'has no error' do
      expect(event.errors).to be_empty
    end

    context 'when event is closed' do
      subject(:event) { FactoryGirl.create(:event_closed) }

      it { expect(closed?).to be_truthy }

      it 'has an error on base' do
        expect(event.errors.added?(:base, :closed)).to be_truthy
      end
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
end
