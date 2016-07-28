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

    before { time_slot.destroy }

    it 'updates its event begin_at_range' do
      values = time_slot.event.time_slots.pluck(:begin_at)

      expect(time_slot.event.reload.begin_at_range).to eq(
        { min: values.min, max: values.max }.as_json
      )
    end
  end

  describe '#title' do
    let(:time_slot) { FactoryGirl.create(:time_slot) }

    subject { time_slot.title }

    it { is_expected.to eq("#{time_slot.event.title} - #{time_slot.begin_at}") }
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

  describe '#receivers_ids_for' do
    let(:time_slot) { FactoryGirl.create(:time_slot, :with_members) }

    subject(:receivers_ids_for) { time_slot.receivers_ids_for(action) }

    %w(join leave).each do |type|
      context "with a #{type} action" do
        let(:action) { double(type: type) }

        it 'returns only the time slot event host id' do
          is_expected.to eq([time_slot.event.host.id])
        end
      end
    end

    context 'with a cancel action' do
      let(:action) { double(type: 'cancel') }

      it 'returns the members profile ids' do
        is_expected.to eq(time_slot.members.pluck('id'))
      end
    end

    context 'with a confirm action' do
      let(:action) { double(type: 'confirm') }

      it 'returns all the event time slots members ids' do
        is_expected.to eq(
          TimeSlotSubmission.where(time_slot_id: time_slot.event.time_slots).pluck('id')
        )
      end
    end

    context 'with unsupported type' do
      it 'raises an error' do
        expect { receivers_ids_for }.to raise_error
      end
    end
  end
end
