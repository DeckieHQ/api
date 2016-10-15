require 'rails_helper'

RSpec.describe CommentPolicy do
  let(:user)    { FactoryGirl.create(:user) }
  let(:comment) { FactoryGirl.create(:comment) }

  subject { CommentPolicy.new(user, comment) }

  context 'being the comment owner' do
    let(:user) { comment.author.user }

    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'being a user moderator' do
    let(:user) { FactoryGirl.create(:user, :moderator) }

    it { is_expected.to permit_action(:update)  }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'being another user' do
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'being the host of the event' do
    let(:user) { comment.resource.host.user }

    it { is_expected.to permit_action(:destroy) }
  end

  context 'posting a comment of comment' do
    let(:comment) { FactoryGirl.create(:comment, :of_comment) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'posting a public comment' do
    it { is_expected.to permit_action(:create) }

    context 'when comment event is recurrent' do
      let(:comment) { FactoryGirl.create(:comment, :of_recurrent_event) }

      it { is_expected.to forbid_action(:create) }

      it do
        is_expected.to have_authorization_error(:event_recurrent, on: :create)
      end
    end
  end

  context 'posting a private comment' do
    let(:comment) { FactoryGirl.create(:comment, :private) }

    context 'being a member of the event' do
      before do
        allow(comment.resource).to receive(:member?).with(user.profile).and_return(true)
      end

      it { is_expected.to permit_action(:create) }
    end

    context 'not being a member of the event' do
      it { is_expected.to forbid_action(:create) }
    end
  end
end
