require 'rails_helper'

RSpec.describe 'Show current location', :type => :request do
  let(:current_location) { FactoryGirl.build(:location_localhost) }

  before do
    get location_path, headers: json_headers
  end

  it { is_expected.to return_status_code 200 }

  it 'returns the current location attributes' do
    expect(response.body).to equal_serialized(current_location)
  end
end
