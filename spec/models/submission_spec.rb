require 'rails_helper'

RSpec.describe Submission, :type => :model do
  it { is_expected.to have_db_index(:event_id) }
  it { is_expected.to have_db_index(:profile_id) }

  it { is_expected.to have_db_index([:event_id, :profile_id]).unique(true) }

  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:profile) }

  let(:submission) { FactoryGirl.build(:submission, status: status) }

  context 'when created' do
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

  context 'when updated' do
    context 'when pending' do
      let(:status) { :pending }

      before do
        submission.save
      end

      context 'with a confirmed status' do
        it 'increases the event attendees_count' do
          expect_to_increase_counter_cache { submission.confirmed! }
        end
      end
    end
  end

  context 'when destroyed' do
    before do
      submission.save
    end

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

    it "propagates event's scopes" do
      expect(
        Submission.event(:opened).pluck(:event_id)
      ).to eq(Event.opened.pluck(:id))
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
