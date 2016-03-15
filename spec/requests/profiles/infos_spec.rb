require 'rails_helper'

RSpec.describe 'Profile infos', :type => :request do
  let(:profile) { FactoryGirl.create(:profile) }

  before do
    get profile_path(profile), headers: json_headers
  end

  it { is_expected.to return_status_code 200 }

  it 'returns the user profile attributes' do
    expect(response.body).to equal_serialized(profile)
  end

  context "when profile doesn't exist" do
    let(:profile) { { id: 0 } }

    it { is_expected.to return_not_found }
  end
end
