require 'rails_helper'

RSpec.describe User, :type => :model do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }

  context 'when created' do
    let(:user) { FactoryGirl.create(:user) }

    it 'has an authentication token' do
      expect(user.authentication_token).to be_present
    end
  end
end
