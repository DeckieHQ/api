require 'rails_helper'

RSpec.describe CleanAccount do
  let(:service) { CleanAccount.new(user) }

  describe '#call' do
    before { service.call }

    context 'when user has hosted events' do
      let(:user) { FactoryGirl.create(:user_with_hosted_events) }

      it 'removes its opened hosted events' do
        expect(user.opened_hosted_events).to be_empty
      end

      it "doesn't remove its closed hosted events" do
        expect(user.hosted_events).to_not be_empty
      end
    end

    context 'when user subscribed to some events' do
      let(:user) { FactoryGirl.create(:user, :with_submissions) }

      it 'removes the submissions to opened events' do
        expect(user.opened_submissions).to be_empty
      end

      it "doesn't remove the submissions to closed events" do
        expect(user.submissions).to_not be_empty
      end
    end
  end
end
