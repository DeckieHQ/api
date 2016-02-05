require 'set'

RSpec.shared_examples 'check parameters for' do |model_name|
  type = model_name.to_s.pluralize

  context 'with empty parameters' do
    let(:params) {}

    it { is_expected.to return_bad_request }
  end

  context 'with empty data' do
    let(:params) { { data: nil } }

    it { is_expected.to return_bad_request }
  end

  context 'with invalid data type' do
    let(:params) { { data: { type: model_name, attributes: {} } } }

    it { is_expected.to return_bad_request }
  end

  context 'with empty data attributes' do
    let(:params) { { data: { type: model_name } } }

    it { is_expected.to return_bad_request }
  end
end
