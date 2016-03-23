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

        it "has a title matching #{factory} #{attribute}" do
          expect(action.title).to eq(resource.send(attribute))
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

    before do
      allow(action.resource).to receive(:send_notifications_for)

      action.save
    end

    it 'asks the resource to send the notifications' do
      expect(action.resource).to have_received(:send_notifications_for).with(action)
    end
  end
end
