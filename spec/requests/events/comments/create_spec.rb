require 'rails_helper'

RSpec.describe 'Create event comment', :type => :request do
  let(:event)          { FactoryGirl.create(:event) }
  let(:comment)        { FactoryGirl.build(:comment) }
  let(:comment_params) { comment.attributes }
  let(:params)         { Serialize.params(comment_params, type: :comments) }

  before do
    post event_comments_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user) }

    let(:authenticate) { user }

    let(:created_comment) { event.comments.last }

    it { is_expected.to return_status_code 201 }

    it 'returns the comment created' do
      expect(response.body).to equal_serialized(created_comment)
    end
  end
end
