require 'set'

RSpec.shared_examples 'check parameters for' do |model_name|
  type = model_name.to_s.pluralize

  let(:parameters) { Parameters.new(params || {}, resource_name: type) }

  context 'with empty parameters' do
    let(:params) {}

    it { is_expected.to return_validation_errors :parameters, { on: :data } }
  end

  context 'with empty data' do
    let(:params) { { data: nil } }

    it { is_expected.to return_validation_errors :parameters, { on: :data } }
  end

  context 'with unexpected data type' do
    let(:params) { { data: { type: '.', attributes: {} } } }

    it { is_expected.to return_validation_errors :parameters, { on: :data } }
  end

  context 'with empty data type and attributes' do
    let(:params) { { data: { type: nil, attributes: nil } } }

    it { is_expected.to return_validation_errors :parameters, { on: :data } }
  end
end
