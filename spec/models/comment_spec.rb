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

  describe 'Relationships' do
    it { is_expected.to belong_to(:author).with_foreign_key(:profile_id) }
    it { is_expected.to belong_to(:resource) }
    it { is_expected.to include_deleted(:author) }
    it { is_expected.to have_many(:comments) }
  end

  describe 'Validations' do
    it { is_expected.to validate_length_of(:message).is_at_most(200) }
  end

  it_behaves_like 'acts as paranoid'

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

  describe '#receiver_ids_for comment' do
    let(:comment) { FactoryGirl.create(:comment, :with_comments) }
    let(:profile) { FactoryGirl.create(:profile) }
    let(:action)  { double(type: 'comment', actor: profile) }

    subject(:receiver_ids_for) { comment.receiver_ids_for(action) }

    it 'returns the profile ids in the comment thread except the author' do
      expected_profiles = comment.comments.pluck('profile_id').push(comment.author.id)

      expected_profiles.delete(action.actor.id)

      is_expected.to eq(expected_profiles)
    end
  end
end
