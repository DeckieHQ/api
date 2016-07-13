require 'rails_helper'

RSpec.describe 'Event search', :type => :search do
  let(:indexable_events) { Event.opened.where(private: false) }

  before(:all) do
    Event.without_auto_index do
      FactoryGirl.create_list(:event,        5)
      FactoryGirl.create_list(:event_closed, 5)
      FactoryGirl.create_list(:event_full,   5)
    end
    Event.reindex!(1000, true)

    sleep 1
  end

  after(:all) do
    Event.clear_index!(true)
  end

  it 'indexes only opened and public events' do
    expect(Event.search('').count).to eq(indexable_events.count)
  end

  let(:event) { indexable_events.sample }

  it 'includes its serialized attributes' do
    result = Event.raw_search('')['hits'].sample

    expect(result).to include_serialized_attributes(
      Event.find(result['objectID']), except: [:opened]
    )
  end

  it 'includes its host serialized attributes' do
    result = Event.raw_search('')['hits'].sample

    expect(result['host']).to include_serialized_attributes(
      Event.find(result['objectID']).host
    )
  end

  [
    :title, :state, :city, :country, :short_description, :description
  ].each do |attribute|
    it "has an index on #{attribute}" do
      value = event.public_send(attribute).split(' ').sample

      expect(Event.search(value)).to_not be_empty
    end
  end

  [:category, :ambiance, :level].each do |attribute|
    it "has faceting on #{attribute}" do
      value = event.public_send(attribute)

      results = Event.search('', {
        facets: attribute, facetFilters: ["#{attribute}:#{value}"]
      })
      expect(results).to have_records(
        indexable_events.where("#{attribute} = ?", value)
      )
    end
  end

  [:auto_accept, :full].each do |attribute|
    it "has boolean filtering on #{attribute}" do
      value = Faker::Number.between(0, 1)

      results = Event.search('', {
        numericFilters: "#{attribute}=#{value}"
      })
      expect(results).to have_records(
        indexable_events.select do |event|
          event.public_send("#{attribute}?") == value.to_b
        end
      )
    end
  end

  [:begin_at, :end_at, :capacity, :attendees_count].each do |attribute|
    it "has numeric filtering on #{attribute}" do
      value = event.public_send(attribute)

      sign = '>='

      numericFilters = if value.is_a?(Integer)
        "#{attribute}#{sign}#{value}"
      else
        "#{attribute}_i#{sign}#{value.to_i}"
      end

      expect(
        Event.search('', { numericFilters: numericFilters })
      ).to have_records(
        indexable_events.where("#{attribute} #{sign} ?", value)
      )
    end
  end

  it 'has geo-search' do
    results = Event.search('', {
      aroundLatLng: "#{event.latitude}, #{event.longitude}", aroundRadius: 50
    })
    expect(results.first.id).to eql(event.id)
  end
end
