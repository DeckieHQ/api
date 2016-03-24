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
    context 'without notify' do
      subject(:action) { FactoryGirl.create(:action) }

      it 'does nothing' do
        is_expected.to be_persisted
      end
    end

    context 'with notify now' do
      subject(:action) { FactoryGirl.create(:action, notify: :now) }

      before do
        allow(ActionNotifierJob).to receive(:perform_now)
      end

      it 'will create the notifications later'do
        expect(ActionNotifierJob).to have_received(:perform_now).with(action)
      end
    end

    context 'without notify later' do
      subject(:action) { FactoryGirl.create(:action, notify: :later) }

      before do
        allow(ActionNotifierJob).to receive(:perform_later)
      end

      it 'will create the notifications later'do
        expect(ActionNotifierJob).to have_received(:perform_later).with(action)
      end
    end
  end

  describe '#resource' do
    let(:action) { FactoryGirl.create(:action) }

    it 'returns also deleted resources' do
      action.resource.destroy

      expect(action.reload.resource).to be_present
    end
  end
end
