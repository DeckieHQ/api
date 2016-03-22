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
    context 'when comment is public' do
      let(:authenticate) { FactoryGirl.create(:user) }
      let(:comment)      { FactoryGirl.build(:comment) }

      it { is_expected.to return_status_code 201 }

      it 'returns the comment created' do
        expect(response.body).to equal_serialized(created_comment)
      end
    end

    context 'when comment is private' do
      context "when user isn't a event's member" do
        let(:authenticate) { FactoryGirl.create(:user) }
        let(:comment)      { FactoryGirl.build(:comment, :private) }

        it { is_expected.to return_forbidden }

        #TODO: add the test "resource is not created"
      end

      context "when user is an event's member" do
        let(:authenticate) { event.attendees.last.user }
        let(:comment)      { FactoryGirl.build(:comment, :private) }

        it { is_expected.to return_status_code 201 }

        it 'returns the comment created' do
          expect(response.body).to equal_serialized(created_comment)
        end
      end

      context "when user is the event host" do
        let(:authenticate) { event.host.user }
        let(:comment)      { FactoryGirl.build(:comment, :private) }

        it { is_expected.to return_status_code 201 }

        it 'returns the comment created' do
          expect(response.body).to equal_serialized(created_comment)
        end
      end
    end
  end
end
