require 'rails_helper'

RSpec.describe Action, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:profile_id) }
    it { is_expected.to have_db_index([:resource_type, :resource_id]) }

    it do
      is_expected.to have_db_column(:title)
        .of_type(:string).with_options(null: false)
    end

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

  describe 'Validations' do
    it { is_expected.to belong_to(:actor).with_foreign_key(:profile_id) }
    it { is_expected.to belong_to(:resource) }
  end

  context 'before create' do
    subject(:action) { FactoryGirl.create(:action, resource: resource) }

    {
      event: :title
    }.each do |factory, attribute|
      context "with #{factory} resource" do
        let(:resource) { FactoryGirl.create(:event) }

        it "has a title matching #{factory} title" do
          expect(action.title).to eq(resource.title)
        end
      end
    end

    context 'with unsupported resource' do
      let(:resource) { FactoryGirl.create(:user) }

      it { expect { action }.to raise_error }
    end
  end

  context 'after create' do
    subject(:action) { FactoryGirl.build(:action) }

    let(:notifiers) { FactoryGirl.create_list(:profile, 5) }

    before do
      allow(action.resource).to receive(:notifiers_for).and_return(notifiers)

      action.save
    end

    it 'asks the resource to get profiles to notify' do
      expect(action.resource).to have_received(:notifiers_for).with(action)
    end

    it 'creates a notification for each profile to notify ' do
      notifiers.each do |profile|
        expect(Notification.find_by(action: action, user: profile.user)).to be_present
      end
    end
  end
end
