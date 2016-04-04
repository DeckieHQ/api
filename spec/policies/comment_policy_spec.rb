require 'rails_helper'

RSpec.describe CommentPolicy do
  subject { CommentPolicy.new(user, comment) }

  context 'being the comment owner' do
    let(:comment) { FactoryGirl.create(:comment) }
    let(:user) { comment.author.user }

    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'being another user' do
    let(:comment) { FactoryGirl.create(:comment) }
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'posting a public comment' do
    let(:comment) { FactoryGirl.create(:comment) }
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to permit_action(:create) }
  end

  context 'posting a private comment' do
    let(:comment) { FactoryGirl.create(:comment, :private) }

    context 'being a member of the event' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        allow(comment.resource).to receive(:member?).with(user.profile).and_return(true)
      end

      it { is_expected.to permit_action(:create) }
    end

    context 'not being a member of the event' do
      let(:user) { FactoryGirl.create(:user) }

      it { is_expected.to forbid_action(:create) }
    end
  end
end
