require 'rails_helper'

RSpec.describe AccountService, :type => :service do
  let(:service) { AccountService.new(user) }

  describe '#cleanup' do
    before { service.cleanup }

    context 'when user has hosted events' do
      let(:user) { FactoryGirl.create(:user_with_hosted_events) }

      it 'removes its opened hosted events' do
        expect(user.hosted_events.opened).to be_empty
      end

      it "doesn't remove its closed hosted events" do
        expect(user.hosted_events).to_not be_empty
      end
    end

    context 'when user subscribed to some events' do
      let(:user) { FactoryGirl.create(:user, :with_subscriptions) }

      it 'removes the subscriptions to opened events' do
        expect(
          user.subscriptions.filter({ event: :opened })
        ).to be_empty
      end

      it "doesn't remove the subscriptions to closed events" do
        expect(user.subscriptions).to_not be_empty
      end
    end
  end
end
