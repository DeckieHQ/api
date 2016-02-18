RSpec.shared_examples 'check parameters for' do |type|
  describe "it checks parameters for #{type}" do
    let(:parameters) { Parameters.new(options || {}, resource_type: type) }
    let(:params)     { options.to_json }

    context 'with empty parameters' do
      let(:options) {}

      it { is_expected.to return_validation_errors :parameters, on: :data }
    end

    context 'with empty data' do
      let(:options) { { data: nil } }

      it { is_expected.to return_validation_errors :parameters, on: :data }
    end

    context 'with invalid data' do
      let(:options) { { data: '' } }

      it { is_expected.to return_validation_errors :parameters, on: :data }
    end

    context 'with unexpected data type' do
      let(:options) { { data: { type: '.', attributes: { test: '' } } } }

      it { is_expected.to return_validation_errors :parameters, on: :data }
    end

    context 'with empty data type' do
      let(:options) { { data: { type: nil, attributes: { test: '' } } } }

      it { is_expected.to return_validation_errors :parameters, on: :data }
    end

    context 'with invalid data attributes' do
      let(:options) { { data: { type: type, attributes: 'test' } } }

      it { is_expected.to return_validation_errors :parameters, on: :data }
    end
  end
end
