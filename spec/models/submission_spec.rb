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

  it_behaves_like 'acts as paranoid'

  context 'after create' do
    subject(:submission) { FactoryGirl.build(:submission) }

    before do
      allow(submission.event).to receive(:update)

      submission.save
    end

    it 'updates event#attendees_count' do
      expect_to_update_counter_cache
    end
  end

  context 'after update' do
    subject!(:submission) { FactoryGirl.create(:submission, status: :pending) }

    before do
      allow(submission.event).to receive(:update)
    end

    context 'when status changed' do
      before do
        submission.confirmed!
      end

      it 'updates event#attendees_count' do
        expect_to_update_counter_cache
      end
    end

    context "when status doesn't change" do
      before do
        submission.update(status: submission.status)
      end

      it "doesn't update event#attendees_count" do
        expect(submission.event).to_not have_received(:update)
      end
    end
  end

  context 'after destroy' do
    subject(:submission) { FactoryGirl.create(:submission) }

    before do
      allow(submission.event).to receive(:update)

      submission.destroy
    end

    it 'updates event#attendees_count' do
      expect_to_update_counter_cache
    end
  end

  def expect_to_update_counter_cache
    expect(submission.event).to have_received(:update)
      .with(attendees_count: submission.event.attendees.count)
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
end
