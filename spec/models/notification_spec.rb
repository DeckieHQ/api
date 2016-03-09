require 'rails_helper'

RSpec.describe Notification, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:user_id)   }
    it { is_expected.to have_db_index(:action_id) }

    it { is_expected.to have_db_index([:user_id, :action_id]).unique }

    it do
      is_expected.to have_db_column(:sent)
        .of_type(:boolean).with_options(null: false, default: false)
    end

    it do
      is_expected.to have_db_column(:viewed)
        .of_type(:boolean).with_options(null: false, default: false)
    end

    it do
      is_expected.to have_db_column(:created_at)
        .of_type(:datetime).with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:updated_at)
        .of_type(:datetime).with_options(null: false)
    end
  end

  describe 'Validations' do
    it { is_expected.to belong_to(:user)   }
    it { is_expected.to belong_to(:action) }
  end
end
