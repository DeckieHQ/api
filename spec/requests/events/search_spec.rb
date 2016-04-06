require 'rails_helper'

RSpec.describe 'Event search', :type => :search do
  before(:all) do
    Event.without_auto_index do
      FactoryGirl.create_list(:event,        5)
      FactoryGirl.create_list(:event_closed, 5)
    end
    Event.reindex!(1000, true)
  end

  after(:all) do
    Event.clear_index!(true)
  end

  let(:event) { Event.opened.sample }

  it 'indexes only opened events' do
    nbHits = Event.raw_search('')['nbHits']

    expect(nbHits).to eq(Event.opened.count)
  end

  it 'has a geolocation filter' do
    result = Event.raw_search('', {
      aroundLatLng: "#{event.latitude}, #{event.longitude}",
      aroundRadius: 50 # In meters
    })
    expect(result['hits'].first['objectID']).to eql(event.id.to_s)
  end
end
