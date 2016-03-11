require 'rails_helper'

RSpec.describe Action, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:profile_id) }
    it { is_expected.to have_db_index([:target_type, :target_id]) }

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
    it { is_expected.to belong_to(:target) }
  end

  context 'when created' do
    subject(:action) { FactoryGirl.create(:action, target: target) }

    {
      event: :title
    }.each do |factory, attribute|
      context "with #{factory} target" do
        let(:target) { FactoryGirl.create(:event) }

        it "has a title matching #{factory} #{attribute}" do
          expect(action.title).to eq(target.send(attribute))
        end
      end
    end

    context 'with unsupported target' do
      let(:target) { FactoryGirl.create(:user) }

      it 'has an empty title' do
        expect(action.title).to be_empty
      end
    end
  end
end
