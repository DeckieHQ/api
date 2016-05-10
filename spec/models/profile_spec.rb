require 'rails_helper'

RSpec.describe Profile, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:user_id).unique(true) }

    it { is_expected.to have_db_column(:avatar).of_type(:string) }

    it do
      is_expected.to have_db_column(:hosted_events_count)
        .of_type(:integer).with_options(null: false, default: 0)
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_length_of(:nickname).is_at_most(64) }
    it { is_expected.to validate_length_of(:short_description).is_at_most(140) }
    it { is_expected.to validate_length_of(:description).is_at_most(8192) }

    context 'with valid avatar' do
      subject(:profile) { FactoryGirl.build(:profile, :with_avatar) }

      it { is_expected.to be_valid }
    end

    context 'with invalid avatar' do
      subject(:profile) { FactoryGirl.build(:profile, :with_invalid_avatar) }

      it { is_expected.to_not be_valid }
    end
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:user) }

    it { is_expected.to have_many(:submissions) }

    it { is_expected.to have_many(:hosted_events) }
  end

  it_behaves_like 'acts as paranoid'

  context 'after update' do
    let!(:profile) { FactoryGirl.create(:profile_with_hosted_events) }

    before do
      allow(ReindexRecordsJob).to receive(:perform_later)
    end

    context 'with changes' do
      before do
        profile.update(nickname: 'blabla')
      end

      it 'plans to reindex its opened_hosted_events' do
        expect(ReindexRecordsJob).to have_received(:perform_later)
          .with('Event', profile.opened_hosted_events.pluck('id'))
      end
    end

    context 'without changes' do
      before do
        profile.update(nickname: profile.nickname)
      end

      it "doesn't plan to reindex its opened_hosted_events" do
        expect(ReindexRecordsJob).to_not have_received(:perform_later)
      end
    end
  end

  describe '#opened_hosted_events' do
    let(:profile) { FactoryGirl.create(:profile_with_hosted_events) }

    subject { profile.opened_hosted_events }

    it 'returns the profile opened hosted events' do
      is_expected.to eq(profile.hosted_events.opened)
    end
  end
end
