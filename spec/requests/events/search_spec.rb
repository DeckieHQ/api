require 'rails_helper'

RSpec.describe 'Event search', :type => :search do
  before(:all) do
    Event.without_auto_index do
      FactoryGirl.create_list(:event,        5)
      FactoryGirl.create_list(:event_closed, 5)
      FactoryGirl.create_list(:event_full,   5)
    end
    Event.reindex!(1000, true)
  end

  after(:all) do
    Event.clear_index!(true)
  end

  it 'indexes only opened events' do
    expect(Event.search('').count).to eq(Event.opened.count)
  end

  let(:event) { Event.opened.sample }

  xit 'has selected attributes' do

  end

  xit "indexes attribute"

  [:category, :ambiance, :level].each do |attribute|
    it "has faceting on #{attribute}" do
      value = event.public_send(attribute)

      results = Event.search('', {
        facets: attribute, facetFilters: ["#{attribute}:#{value}"]
      })
      expect(results).to equal_search(
        Event.opened.where("#{attribute} = ?", value)
      )
    end
  end

  [:auto_accept, :full].each do |attribute|
    it "has filtering on #{attribute}" do
      value = Faker::Number.between(0, 1)

      results = Event.search('', {
        numericFilters: "#{attribute}=#{value}"
      })
      expect(results).to equal_search(
        Event.opened.select do |event|
          event.public_send("#{attribute}?") == value.to_b
        end
      )
    end
  end

  [:begin_at, :end_at].each do |attribute|
    it "has date filtering on #{attribute}" do
      value = event.public_send(attribute)

      results = Event.search('', {
        numericFilters: "#{attribute}_i>#{value.to_i}"
      })
      expect(results).to equal_search(
        Event.opened.where("#{attribute} > ?", value)
      )
    end
  end

  xit 'has ranking'
  # TODO: test attributes presence

  xit 'has custom ranking' do

  end

  it 'has geo-search' do
    results = Event.search('', {
      aroundLatLng: "#{event.latitude}, #{event.longitude}", aroundRadius: 50
    })
    expect(results.first.id).to eql(event.id)
  end

  xit do
    byebug
  end
end
