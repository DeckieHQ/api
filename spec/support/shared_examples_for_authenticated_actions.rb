require 'set'

RSpec.shared_examples 'an action requiring authentication' do
  let(:params) {}

  context 'when user is not authenticated' do
    let(:authenticated) { false }

    it { is_expected.to return_status_code 401 }

    it 'returns an unauthorized error' do
      expected_response = { error: I18n.t('failure.unauthorized') }

      expect(json_response).to eq expected_response
    end
  end

  context 'when authentication token is invalid' do
    let(:user) do
      FactoryGirl.build(:user) do |user|
        user.authentication_token = Faker::Internet.password
      end
    end

    let(:authenticated) { true }

    it { is_expected.to return_status_code 401 }

    it 'returns an unauthorized error' do
      expected_response = { error: I18n.t('failure.unauthorized') }

      expect(json_response).to eq expected_response
    end
  end
end
