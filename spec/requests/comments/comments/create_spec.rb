require 'rails_helper'

RSpec.describe 'Answer comment', :type => :request do
  let(:parent)          { FactoryGirl.create(:comment) }
  let(:comment_params)  { comment.attributes }
  let(:params)          { Serialize.params(comment_params, type: :comments) }
  let(:created_comment) { parent.comments.last }
  let(:comment)         { FactoryGirl.build(:comment) }

  before do
    post comment_comments_path(parent), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)         { FactoryGirl.create(:user) }
    let(:authenticate) { user }

    context 'when comment parent has a comment parent itself' do
      let(:parent) { FactoryGirl.create(:comment, :of_comment) }

      it { is_expected.to return_forbidden }

      it "doesn't create the comment" do
        expect(parent.comments).to be_empty
      end
    end

    context 'when comment parent is an event comment' do
      context 'when comment parent is public' do
        it { is_expected.to return_status_code 201 }

        it 'creates a new comment with permited parameters' do
          permited_params = comment.slice(:message)

          expect(created_comment).to have_attributes(permited_params)
          expect(created_comment.author).to eq(user.profile)
        end

        it 'returns the comment created' do
          expect(response.body).to equal_serialized(created_comment)
        end
      end

      context 'when comment parent is private' do
        let(:parent) { FactoryGirl.create(:comment, :private) }

        context "when user isn't a event's member" do
          it { is_expected.to return_forbidden }

          it "doesn't create the comment" do
            expect(parent.comments).to be_empty
          end
        end

        context "when user is an event's member" do
          let(:user) { parent.resource.host.user }

          it { is_expected.to return_status_code 201 }

          it 'creates a new comment with permited parameters' do
            permited_params = comment.slice(:message)

            expect(created_comment).to have_attributes(permited_params)
            expect(created_comment.author).to eq(user.profile)
          end

          it 'returns the comment created' do
            expect(response.body).to equal_serialized(created_comment)
          end
        end
      end
    end
  end
end
