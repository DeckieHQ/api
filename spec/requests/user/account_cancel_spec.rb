require 'rails_helper'

RSpec.describe 'User account cancel', :type => :request do
  before do
    delete user_path, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)         { FactoryGirl.create(:user) }
    let(:authenticate) { user }

    it { is_expected.to return_no_content }

    it 'deletes the user' do
      expect(User.find_by(email: user.email)).to_not be_present
    end

    context 'when user has hosted events' do
      let(:user) { FactoryGirl.create(:user_with_hosted_events) }

      it 'deletes the user opened hosted events' do
        expect(user.opened_hosted_events).to be_empty
      end

      it "doesn't delete the user closed hosted events" do
        expect(user.hosted_events).to_not be_empty
      end
    end

    context 'when user has submissions' do
      let(:user) { FactoryGirl.create(:user, :with_submissions) }

      it 'deletes the user submissions to opened events' do
        expect(user.opened_submissions).to be_empty
      end

      it "doesn't delete the user submissions to closed events" do
        expect(user.submissions).to_not be_empty
      end
    end

    context('when user has time slot submissions') do
      let(:user) { FactoryGirl.create(:user, :with_time_slot_submissions) }

      it 'deletes the user time slot submissions' do
        expect(user.time_slot_submissions).to be_empty
      end
    end
  end
end
