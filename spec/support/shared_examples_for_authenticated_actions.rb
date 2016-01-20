require 'set'

RSpec.shared_examples 'an action requiring authentication' do
  context 'when user is not authenticated' do
    let(:authenticated) { false }

    it { is_expected.to return_status_code 401 }

    it 'returns an unauthorized error' do
      expected_response = { error: I18n.t('failure.unauthorized') }

      expect(json_response).to eq expected_response
    end
  end
end
