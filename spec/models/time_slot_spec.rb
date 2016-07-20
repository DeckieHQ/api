require 'rails_helper'

RSpec.describe TimeSlot, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:event_id) }

    [:begin_at, :created_at, :updated_at].each do |attribute|
      it do
        is_expected.to have_db_column(attribute)
          .of_type(:datetime).with_options(null: false)
      end
    end

    it do
      is_expected.to have_db_column(:members_count)
        .of_type(:integer).with_options(null: false, default: 0)
    end

    it { is_expected.to have_db_index([:event_id, :begin_at]).unique(true) }
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:event) }

    it { is_expected.to have_many(:time_slot_submissions).dependent(:destroy) }

    it { is_expected.to have_many(:members).through(:time_slot_submissions).source(:profile) }
  end

  describe 'after destroy' do
    subject(:time_slot) { FactoryGirl.create(:time_slot) }

    before do
      allow(ReindexRecordsJob).to receive(:perform_later)

      time_slot.destroy
    end

    it 'plans to reindex its event' do
      expect(ReindexRecordsJob).to have_received(:perform_later)
        .with('Event', [time_slot.event.id])
    end
  end

  describe '#member?' do
    let(:time_slot) { FactoryGirl.create(:time_slot) }

    let(:profile) { FactoryGirl.create(:profile) }

    subject { time_slot.member?(profile) }

    it { is_expected.to be_falsy }

    context 'when profile is a time slot member' do
      before { time_slot.members << profile }

      it { is_expected.to be_truthy }
    end
  end

  [:full, :closed].each do |state|
    describe "##{state}?" do
      let(:time_slot) { FactoryGirl.create(:time_slot) }

      subject { time_slot.public_send(:"#{state}?") }

      it { is_expected.to be_falsy }

      context "when time slot is #{state}" do
        let(:time_slot) { FactoryGirl.create(:time_slot, state) }

        it { is_expected.to be_truthy }
      end
    end
  end
end
