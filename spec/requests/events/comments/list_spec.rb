require 'rails_helper'

RSpec.describe 'List event comments', :type => :request do
  let(:event) { FactoryGirl.create(:event, :with_comments) }

  before do
    get event_comments_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action with sorting', :event, :comments, accept: %w(created_at)
end
