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
    it { is_expected.to validate_presence_of(:message) }

    it { is_expected.to validate_length_of(:message).is_at_most(200) }
  end

  it_behaves_like 'acts as paranoid'

  context 'after create' do
    context 'with Comment resource' do
      subject(:comment) { FactoryGirl.build(:comment, :of_comment) }

      it { expect(comment.save).to be_truthy }
    end

    context 'with another resource' do
      let(:comment) { FactoryGirl.build(:comment) }

      it 'updates the resource counter cache' do
        prefix = comment.private? ? :private : :public

        expect { comment.save }.to change {
          comment.resource.public_send("#{prefix}_comments_count")
        }.by(1)
      end
    end
  end

  describe '.title' do
    let(:comment) { FactoryGirl.create(:comment) }

    it 'has a title' do
      expect(comment.title).to eq(comment.message.first(40))
    end
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

  describe '#top_resource' do
    let(:comment) { FactoryGirl.create(:comment) }

    subject { comment.top_resource }

    it 'delegates its resource top resource' do
      is_expected.to eq(comment.resource.top_resource)
    end
  end

  describe '#receivers_ids_for comment' do
    let(:comment) { FactoryGirl.create(:comment, :with_comments) }

    let(:profile) { FactoryGirl.create(:profile) }

    let(:action)  { double(type: 'comment', actor: profile) }

    subject(:receivers_ids_for) { comment.receivers_ids_for(action) }

    it 'returns the profile ids in the comment thread except the author' do
      is_expected.to eq(
        comment.comments.pluck('profile_id').push(comment.author.id).tap do |ids|
          ids.delete(action.actor.id)
        end
      )
    end
  end
end
