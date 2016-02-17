RSpec.shared_examples 'an action with sorting' do |owner_name, collection_name, options|
  accept = options[:accept]

  let(:page) { FactoryGirl.build(:page_default) }

  let(:collection) { send(owner_name).send(collection_name) }

  let(:sorted_collection) do
    collection.order(sort.params).pluck(:id).take(page.size)
  end

  let(:params) { Serialize.query(sort: sort_attributes) }

  let(:sort) { Sort.new(sort_attributes, accept: accept) }

  context 'with an invalid sort' do
    let(:sort_attributes) { { is: :not_a_string } }

    it { is_expected.to return_search_errors :sort }
  end

  context 'with supported sort' do
    let(:sort_attributes) { accept.shuffle.map(&:to_s).join(',') }

    it { is_expected.to return_status_code 200 }

    it "returns a sorted #{owner_name} #{collection_name} list" do
      expect(json_response[:data].pluck(:id)).to eq(
        collection.order(sort.params).pluck(:id).take(page.size).map(&:to_s)
      )
    end
  end
end
