require 'rails_helper'

RSpec.describe Location, :type => :model do
  let(:latitude) { Faker::Address.latitude }

  let(:longitude) { Faker::Address.longitude }

  subject(:location) do
    described_class.new({ 'latitude' => latitude, 'longitude' => longitude })
  end

  it 'has the given latitude' do
    expect(location.latitude).to eq(latitude.to_f)
  end

  it 'has the given longitude' do
    expect(location.longitude).to eq(longitude.to_f)
  end
end
