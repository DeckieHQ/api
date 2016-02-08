require 'set'

RSpec.shared_examples 'check parameters for' do |type|
  let(:parameters) { Parameters.new(params || {}, resource_type: type.to_s) }

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
