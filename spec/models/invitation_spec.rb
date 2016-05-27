require 'rails_helper'

RSpec.describe Invitation, :type => :model do
  describe 'Database' do
    it { is_expected.to have_db_index(:event_id) }

    it { is_expected.to have_db_index([:event_id, :email]).unique(true) }

    it do
      is_expected.to have_db_column(:email)
        .of_type(:string).with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:message)
        .of_type(:text).with_options(null: false)
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
    it { is_expected.to belong_to(:event) }
  end

  describe 'Validations' do
    subject(:invitation) { FactoryGirl.build(:invitation) }
    
    [:email, :message].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end

    it do
      is_expected.to validate_uniqueness_of(:email).scoped_to(:event_id).case_insensitive
    end

    it { is_expected.to validate_length_of(:message).is_at_most(512) }

    context 'with valid email' do
      subject(:invitation) { FactoryGirl.build(:invitation) }

      it { is_expected.to be_valid }
    end

    context 'with invalid email' do
      subject(:invitation) { FactoryGirl.build(:invitation, :with_invalid_email) }

      it { is_expected.to_not be_valid }
    end
  end
end
