require 'rails_helper'

RSpec.describe 'Destroy event comment', :type => :request do
  let(:comment) { FactoryGirl.create(:comment) }

  before do
    delete comment_path(comment), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:authenticate) { user }

    context "when comment doesn't exist" do
      let(:user) { FactoryGirl.create(:user) }

      let(:comment) { { id: 0 } }

      it { is_expected.to return_not_found }
    end

    context 'when user has no access to the comment' do
      let(:user) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it "doesn't destroy the comment" do
        expect(comment.reload).to be_persisted
      end
    end

    context 'when comment belongs to the user' do
      let(:user) { comment.author.user }

      it { is_expected.to return_no_content }

      it 'destroys the comment' do
        expect(Comment.find_by(id: comment.id)).to be_nil
      end
    end
  end
end
