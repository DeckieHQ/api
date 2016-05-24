require 'rails_helper'

RSpec.describe 'List profile achievements', :type => :request do
  let(:params) {}

  before do
    get profile_achievements_path(profile), params: params, headers: json_headers
  end

  let(:profile) do
    FactoryGirl.create(:user).tap do |u|
      u.add_badge(1)
      u.add_badge(2)
      u.add_badge(3)
    end.profile
  end

  it 'returns the profile badges' do
    expect(response.body).to equal_serialized(profile.user.badges)
  end

  context "when profile doesn't exist" do
    let(:profile) { { profile_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
