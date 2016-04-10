require 'rails_helper'

RSpec.describe Notification, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:user_id)   }
    it { is_expected.to have_db_index(:action_id) }

    it { is_expected.to have_db_index([:user_id, :action_id]).unique }

    it do
      is_expected.to have_db_column(:type)
        .of_type(:string).with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:viewed)
        .of_type(:boolean).with_options(null: false, default: false)
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
    it { is_expected.to belong_to(:user)   }
    it { is_expected.to belong_to(:action) }

    it { is_expected.to include_deleted(:action) }
  end

  context 'after create' do
    let(:user) do
      FactoryGirl.create(:user, notifications_count: Faker::Number.between(0, 5))
    end

    subject(:notification) { FactoryGirl.create(:notification, user: user) }

    it 'sets the type according to action attributes' do
      action = notification.action

      expect(notification.type).to eq(
        "#{action.resource_type.downcase}-#{action.type}"
      )
    end

    it 'increments user notifications_count' do
      expect { notification }.to change { user.notifications_count }.by(1)
    end
  end

  describe '#viewed!' do
    let(:notification) { FactoryGirl.create(:notification, viewed: false) }

    before do
      notification.tap(&:viewed!).reload
    end

    it 'updates the notification with viewed = true' do
      expect(notification).to be_viewed
    end
  end
end
