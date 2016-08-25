require 'rails_helper'

RSpec.describe EmailDelivery, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:user_id) }

    it { is_expected.to have_db_index([:resource_type, :resource_id]) }

    it do
      is_expected.to have_db_column(:type)
        .of_type(:string).with_options(null: false)
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

  describe 'Relationships' do
    it { is_expected.to belong_to(:receiver).class_name('User').with_foreign_key(:user_id) }

    it { is_expected.to belong_to(:resource) }
  end
end
