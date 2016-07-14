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

    it { is_expected.to have_db_index([:event_id, :begin_at]).unique(true) }
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:event) }
  end
end
