require 'rails_helper'

RSpec.describe Comment, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:profile_id) }
    it { is_expected.to have_db_index([:resource_type, :resource_id]) }

    it do
      is_expected.to have_db_column(:message)
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

  describe 'Validations' do
    it { is_expected.to belong_to(:author).with_foreign_key(:profile_id) }
    it { is_expected.to belong_to(:resource) }
  end
end
