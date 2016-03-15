RSpec.shared_examples 'an action with include' do |owner_name, collection_name, options|
  options = options || collection_name

  accept = options[:accept]
  on     = options[:on] || :collection

  let(:page) { FactoryGirl.build(:page_default) }

  let(:collection) do
    if on == :collection
      send(owner_name).send(collection_name).take(page.size)
    else
      [send(owner_name)]
    end
  end

  let(:params) { Serialize.query(include: include_attributes) }

  context 'with invalid include' do
    let(:includes) { Include.new(include_attributes, accept: accept) }

    let(:include_attributes) { { is: :not_a_string } }

    it { is_expected.to return_search_errors :includes, on: :include }
  end

  context 'with supported include' do
    let(:include_attributes) { accept.shuffle.join(',') }

    it { is_expected.to return_status_code 200 }

    accept.each do |relationship|
      it "returns the included #{relationship.pluralize}" do
        expect(
          { data: included_relations_for(relationship) }.to_json
        ).to equal_serialized(
          collection_relations_for(relationship)
        )
      end
    end
  end

  def included_relations_for(relationship)
    json_response[:included].select do |member|
      member[:type] == relation_type(relationship)
    end
  end

  # Returns the type of the resource of the relation.
  # e.g. Event host is a profile object, including 'event.host' should return
  # objects with type 'profiles' instead of 'hosts'.
  def relation_type(relationship)
    collection_relations_for(relationship).first.class.name.downcase.pluralize
  end

  # This doesn't support hasMany relationships as we should never accept
  # hasMany relationships as a valid include.
  def collection_relations_for(relationship)
    relationship.split('.').inject(collection) do |relations, relation_name|
      relations.map(&:"#{relation_name}")
    end
  end
end
