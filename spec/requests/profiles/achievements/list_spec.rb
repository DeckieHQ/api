require 'rails_helper'

RSpec.describe 'List profile achievements', :type => :request do
  let(:params) {}

  before do
    get profile_achievements_path(profile), params: params, headers: json_headers
  end

  let(:profile) { FactoryGirl.create(:profile, :with_achievements) }

  it 'returns the profile achievements' do
    expect(response.body).to equal_serialized(profile.achievements)
  end

  context "when profile doesn't exist" do
    let(:profile) { { profile_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
