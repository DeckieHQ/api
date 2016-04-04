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
