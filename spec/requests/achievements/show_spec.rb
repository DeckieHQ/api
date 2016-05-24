require 'rails_helper'

RSpec.describe 'Achievement show', :type => :request do
  let(:achievement) { Merit::Badge.find(1) }

  before do
    get achievement_path(achievement), headers: json_headers
  end

  it { is_expected.to return_status_code 200 }

  it 'returns the achievement attributes' do
    expect(response.body).to equal_serialized(achievement)
  end

  context "when achievement doesn't exist" do
    let(:achievement) { { id: 0 } }

    it { is_expected.to return_not_found }
  end
end
