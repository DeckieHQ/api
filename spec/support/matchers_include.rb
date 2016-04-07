require 'rspec/expectations'

RSpec::Matchers.define :include_deleted do |relationship|
  match do
    collection.first.public_send(relationship).destroy

    described_class.all.includes(relationship).each do |member|
      member_relationship = member.public_send(relationship)

      expect(member_relationship).to_not be_nil
    end
  end

  def collection
    FactoryGirl.create_list(described_class.to_s.downcase, 3)
  end
end

RSpec::Matchers.define :include_serialized_attributes do |model|
  match do |actual|
    serializer = "#{model.class}Serializer".constantize.new(model)

    expect(actual).to include(JSON.parse(serializer.attributes.to_json))
  end
end


RSpec::Matchers.define :include_records do |records|
  match do |results|
    resultIds = results.pluck('id')

    recordIds = records.pluck('id')

    recordIds.all? { |id| resultIds.include?(id) }
  end
end
