require 'rails_helper'

RSpec.describe TimeSlotSubmission, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:time_slot_id) }

    it { is_expected.to have_db_index(:profile_id) }

    [:created_at, :updated_at].each do |attribute|
      it do
        is_expected.to have_db_column(attribute)
          .of_type(:datetime).with_options(null: false)
      end
    end

    it { is_expected.to have_db_index([:time_slot_id, :profile_id]).unique(true) }
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:time_slot).counter_cache(:members_count) }

    it { is_expected.to belong_to(:profile) }
  end
end
