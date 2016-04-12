require 'rails_helper'

RSpec.describe Submission, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:event_id) }
    it { is_expected.to have_db_index(:profile_id) }

    it { is_expected.to have_db_index([:event_id, :profile_id]).unique(true) }
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:event).counter_cache }

    it { is_expected.to belong_to(:profile) }

    it { is_expected.to include_deleted(:profile) }
  end

  context 'after create' do
    subject(:submission) { FactoryGirl.build(:submission, status: status) }

    context 'with a confirmed status' do
      let(:status) { :confirmed }

      it 'increases the event attendees_count' do
        expect_to_increase_counter_cache { submission.save }
      end
    end

    context 'with another status' do
      let(:status) { :pending }

      it "doesn't change the event attendees_count" do
        expect_to_not_change_counter_cache { submission.save }
      end
    end
  end

  context 'after update' do
    subject(:submission) { FactoryGirl.create(:submission, status: status) }

    context 'when pending' do
      let(:status) { :pending }

      context 'with a confirmed status' do
        it 'increases the event attendees_count' do
          expect_to_increase_counter_cache { submission.confirmed! }
        end
      end
    end
  end

  context 'after destroy' do
    subject(:submission) { FactoryGirl.create(:submission, status: status) }

    context 'when confirmed' do
      let(:status) { :confirmed }

      it 'descreases the event attendees_count' do
        expect_to_decrease_counter_cache { submission.destroy }
      end
    end

    context 'when not confirmed' do
      let(:status) { :pending }

      it "doesn't change the event attendees_count" do
        expect_to_not_change_counter_cache { submission.destroy }
      end
    end
  end

  it_behaves_like 'acts as paranoid'

  describe '.status' do
    before do
      FactoryGirl.create_list(:submission, 5)
    end

    let(:results) { Submission.status(status) }

    [:confirmed, :pending].each do |state|
      context "when status equals #{state}" do
        let(:status) { state }

        it "returns the #{state} submissions" do
          expect(results).to eq(Submission.send(status))
        end
      end
    end

    [:unkown, 0, nil].each do |state|
      context "when status equals #{state}" do
        let(:status) { state }

        it 'returns an empty collection' do
          expect(results).to eq(Submission.none)
        end
      end
    end
  end

  describe '.event' do
    before do
      FactoryGirl.create_list(:submission, 5)
    end

    # We need to order by id, somehow joins and pluck combined are messing
    # with the order of the objects returned when objects have the same
    # created_at value.
    it "propagates event's scopes" do
      order = { id: :desc }

      expect(
        Submission.event(:opened).order(order).pluck(:event_id)
      ).to eq(
        Event.opened.order(order).pluck(:id)
      )
    end
  end

  def expect_to_increase_counter_cache(&action)
    expect_to_change_counter_cache_by(1, &action)
  end

  def expect_to_decrease_counter_cache(&action)
    expect_to_change_counter_cache_by(-1, &action)
  end

  def expect_to_change_counter_cache_by(value, &action)
    expect(action).to change { submission.event.attendees_count }.by(value)
  end

  def expect_to_not_change_counter_cache(&action)
    expect(action).to_not change { submission.event.attendees_count }
  end
end
