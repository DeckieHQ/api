require 'rails_helper'

RSpec.describe 'Create event comment', :type => :request do
  let(:event)           { FactoryGirl.create(:event_with_attendees) }
  let(:comment_params)  { comment.attributes }
  let(:params)          { Serialize.params(comment_params, type: :comments) }
  let(:created_comment) { event.comments.last }

  before do
    post event_comments_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)            { FactoryGirl.create(:user) }
    let(:authenticate)    { user }
    
    context 'when comment is public' do
      let(:comment)      { FactoryGirl.build(:comment) }

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

    context 'when comment is private' do
      context "when user isn't a event's member" do
        let(:comment)      { FactoryGirl.build(:comment, :private) }

        it { is_expected.to return_forbidden }

        it "doesn't create the comment" do
          expect(event.comments).to be_empty
        end
      end

      context "when user is an event's member" do
        let(:user)    { event.attendees.last.user }
        let(:comment) { FactoryGirl.build(:comment, :private) }

        it { is_expected.to return_status_code 201 }

        it 'creates a new comment with permited parameters' do
          permited_params = comment.slice(:message, :private)

          expect(created_comment).to have_attributes(permited_params)
          expect(created_comment.author).to eq(user.profile)
        end

        it 'returns the comment created' do
          expect(response.body).to equal_serialized(created_comment)
        end
      end

      context "when user is the event host" do
        let(:user)    { event.host.user }
        let(:comment) { FactoryGirl.build(:comment, :private) }

        it { is_expected.to return_status_code 201 }

        it 'creates a new comment with permited parameters' do
          permited_params = comment.slice(:message, :private)

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
