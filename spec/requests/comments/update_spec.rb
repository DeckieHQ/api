require 'rails_helper'

RSpec.describe 'Comment update', :type => :request do
  let(:params) { Serialize.params(comment_update_params, type: :comments) }

  let(:comment)               { FactoryGirl.create(:comment) }
  let(:comment_update)        { FactoryGirl.build(:comment) }
  let(:comment_update_params) { comment_update.attributes }

  let(:permited_params) do
    comment_update.slice(:message)
  end

  before do
    put comment_path(comment), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'with comment owner' do
      before { comment.reload }

      let(:authenticate) { comment.author.user }

      include_examples 'check parameters for', :comments

      context 'when attributes are valid' do
        it { is_expected.to return_status_code 200 }

        it 'returns the comment attributes' do
          expect(response.body).to equal_serialized(comment)
        end

        it 'updates the comment with permited params' do
          expect(comment).to have_attributes(permited_params)
        end
      end

      context 'when attributes are not valid' do
        let(:comment_update) { FactoryGirl.build(:comment_invalid) }

        it { is_expected.to return_status_code 422 }
        it { is_expected.to return_validation_errors :comment_update }
      end
    end

    context 'with another user' do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it "doesn't update the comment" do
        expect(comment).to_not have_been_changed
      end
    end

    context "when comment doesn't exist" do
      let(:authenticate) { FactoryGirl.create(:user) }

      let(:comment) { { id: 0 } }

      it { is_expected.to return_not_found }
    end
  end
end
