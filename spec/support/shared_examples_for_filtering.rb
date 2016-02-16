RSpec.shared_examples 'an action with filtering' do |owner_name, collection_name, options|
  filter_with = options[:with]

  order = options[:order] || { id: :desc}

  let(:page) { FactoryGirl.build(:page_default) }

  let(:collection) { send(owner_name).send(collection_name).order(order) }

  let(:complete_collection) { collection.paginate(page.params) }

  let(:params) { Serialize.query(filters: filters) }

  context 'when filters are empty' do
    let(:filters) {}

    it { is_expected.to return_status_code 200 }

    it "returns the complete #{owner_name} #{collection_name} list" do
      expect(response.body).to equal_serialized(complete_collection)
    end
  end

  context 'with an invalid filter' do
    let(:filters) { { lol: 1 } }

    it { is_expected.to return_status_code 200 }

    it "ignores the filter" do
      expect(response.body).to equal_serialized(complete_collection)
    end
  end

  filter_with.each do |filter, values|
    values.each do |value|

      context "when filtering with #{filter} = #{value}" do
        let(:filters) { { filter => value } }

        it { is_expected.to return_status_code 200 }

        it "returns the filtered #{owner_name} #{collection_name} list" do
          expect(response.body).to equal_serialized(
            collection.send(filter, value).paginate(page.params)
          )
        end
      end

    end
  end
end
