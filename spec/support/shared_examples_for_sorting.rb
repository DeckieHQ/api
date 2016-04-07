RSpec.shared_examples 'an action with sorting' do |owner_name, collection_name, options = {}|
  accept = options[:accept]

  let(:page) { FactoryGirl.build(:page_default) }

  let(:collection) { send(owner_name).send(collection_name) }

  let(:params) { Serialize.query(sort: sort_attributes) }

  let(:sort) { Sort.new(sort_attributes, accept: accept) }

  context 'with an invalid sort' do
    let(:sort_attributes) { { is: :not_a_string } }

    it { is_expected.to return_search_errors :sort, on: :sort }
  end

  context 'with supported sort' do
    let(:sort_attributes) { accept.shuffle.join(',') }

    let(:sorted_collection) do
      collection.joins(sort.joins).reorder(sort.params).paginate(page.params)
    end

    it { is_expected.to return_status_code 200 }

    it "returns a sorted #{owner_name} #{collection_name} list" do
      expect(response.body).to equal_serialized(sorted_collection)
    end
  end
end
