require 'rails_helper'

RSpec.describe Parameters, :type => :model do
  let(:type) { Faker::Lorem.word }

  subject(:parameters) do
    params = { data: data }

    Parameters.new(params, resource_type: type)
  end

  before do
    parameters.validate
  end

  [nil, 'not a hash'].each do |value|
    context "when data is #{value}" do
      let(:data) { value }

      it 'has a validation error on base' do
        expect(parameters.errors.added?(:base, :missing_data)).to be_truthy
      end
    end
  end

  [:type, :attributes].each do |key|
    context "when data #{key} is missing" do
      let(:data) { { key => nil } }

      it "has a validation error on #{key}" do
        expect(parameters.errors.added?(key, :blank)).to be_truthy
      end
    end
  end

  context "when data type doesn't match resource name" do
    let(:data) { { type: "#{type}." } }

    it 'has a validation error on type' do
      expect(
        parameters.errors.added?(:type, :unmatch, { resource_type: type })
      ).to be_truthy
    end
  end

  [nil, 'not a hash'].each do |value|
    context "when data attributes is #{value}" do
      let(:data) { { type: type, attributes: value } }

      it 'has a validation error on attributes' do
        expect(
          parameters.errors.added?(:attributes, :invalid)
        ).to be_truthy
      end
    end
  end
end
