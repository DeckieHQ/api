RSpec.shared_examples 'an action with pagination' do |owner_name, collection_name, options|
  let(:collection) { send(owner_name).send(collection_name) }

  let(:paginated_collection) do
    collection.paginate((page || FactoryGirl.build(:page_default)).params)
  end

  let(:page) do
    size   = collection.count / Faker::Number.between(2, 3)
    number = Faker::Number.between(1, size + 1)

    FactoryGirl.build(:page, number: number, size: size)
  end

  let(:params) { Serialize.query(page: page) }

  before do
  #  p "expected: %#{page.params}"
  #  p collection.pluck('id')
  end

  it { is_expected.to return_status_code 200 }

  it "returns the #{owner_name} paginated #{collection_name} list" do
    expect(response.body).to equal_serialized(paginated_collection)
  end

  context 'with empty pagination parameters' do
    let(:page) {}

    it { is_expected.to return_status_code 200 }

    it "returns the default #{owner_name} paginated #{collection_name} list" do
      expect(response.body).to equal_serialized(paginated_collection)
    end
  end

  context 'with invalid pagination parameters' do
    let(:page) { FactoryGirl.build(:page_invalid) }

    it { is_expected.to return_search_errors :page, on: :page }
  end

  context 'with unexisting page' do
    let(:page) do
      FactoryGirl.build(:page, number: collection.count + 1, size: 1)
    end

    it { is_expected.to return_status_code 200 }

    it 'returns an empty list' do
      expect(json_response[:data]).to be_empty
    end
  end
end
