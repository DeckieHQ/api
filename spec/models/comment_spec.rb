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
    it { is_expected.to validate_length_of(:message).is_at_most(200) }
    it { is_expected.to have_many(:comments) }
  end

  describe '.publics' do
    let(:event) { FactoryGirl.create(:event, :with_comments) }

    it 'returns the public comments' do
      expect(event.public_comments).to eq(event.comments.where(private: false))
    end
  end

  describe '.privates' do
    let(:event) { FactoryGirl.create(:event, :with_comments) }

    ['true', true, 1].each do |value|
      context "when parameter equals #{value}" do
        it 'returns the private comments' do
          expect(event.comments.privates(value)).to eq(event.comments.where(private: true))
        end
      end
    end
  end
end
