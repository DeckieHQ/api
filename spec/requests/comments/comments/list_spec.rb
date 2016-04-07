require 'rails_helper'

RSpec.describe 'List comment answers', :type => :request do
  let(:params) {}

  before do
    get comment_comments_path(parent), params: params, headers: json_headers
  end

  context "when comment is public" do
    let(:parent) { FactoryGirl.create(:comment, :with_comments) }

    it_behaves_like 'an action with pagination', :parent, :comments

    it_behaves_like 'an action with sorting', :parent, :comments, accept: %w(created_at)

    it_behaves_like 'an action with include', :parent, :comments, accept: %w(author)
  end

  context "when comment is private" do
    let(:parent) { FactoryGirl.create(:comment, :private, :with_comments) }

    context "when user isn't an event's member" do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }
    end

    context "when user is an event's member" do
      let(:authenticate) { parent.resource.host.user }

      it_behaves_like 'an action with pagination', :parent, :comments

      it_behaves_like 'an action with sorting', :parent, :comments, accept: %w(created_at)

      it_behaves_like 'an action with include', :parent, :comments, accept: %w(author)
    end
  end
end
