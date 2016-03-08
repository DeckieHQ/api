RSpec.shared_examples 'an action with include' do |owner_name, collection_name, options|
  accept = options[:accept]

  let(:page) { FactoryGirl.build(:page_default) }

  let(:collection) { send(owner_name).send(collection_name).take(page.size) }

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
      relationship_type = relationship.pluralize

      it "returns the included #{relationship_type}" do
        data = json_response[:included].select do |member|
          member[:type] == relationship_type
        end
        expect({ data: data }.to_json).to equal_serialized(
          collection.map(&:"#{relationship}")
          # This hasn't been tested on many-to-many relationships.
          # I guess adding .flatten should do the trick.
        )
      end
    end
  end
end
