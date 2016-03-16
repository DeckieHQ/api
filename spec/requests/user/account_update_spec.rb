require 'rails_helper'

RSpec.describe 'User account update', :type => :request do
  let(:params) { Serialize.params(account_update_params, type: :users) }

  let(:account_update_params) { user_update.attributes }

  let(:user_update) { FactoryGirl.build(:user_with_phone_number) }

  before do
    put user_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)         { FactoryGirl.create(:user) }
    let(:authenticate) { user }

    before { user.reload }

    include_examples 'check parameters for', :users

    context 'when attributes are valid' do
      let(:account_update_params) do
        user_update.attributes.merge(current_password: user.password)
      end

      it { is_expected.to return_status_code 200 }

      it 'returns the user attributes' do
        expect(response.body).to equal_serialized(user)
      end

      it 'updates the user with permited params' do
        permited_params = user_update.slice(
          :email, :first_name, :last_name, :birthday, :phone_number, :culture
        )
        expect(user).to have_attributes(permited_params)
      end

      context 'when password is specified' do
        let(:account_update_params) do
          user_update.attributes.merge(
            current_password: user.password,
            password: user_update.password
          )
        end

        it 'changes the user password' do
          expect(user.valid_password?(user_update.password)).to be_truthy
        end
      end
    end

    context 'when current password is invalid' do
      let(:account_update_params) do
        user_update.attributes.merge(current_password: '.')
      end

      before do
        user_update.errors.add(:current_password, :invalid)
      end

      it { is_expected.to return_validation_errors :user_update }
    end

    context 'when attributes are not valid' do
      let(:user_update) { FactoryGirl.build(:user_invalid) }

      before do
        user_update.tap(&:valid?).errors.add(:current_password, :blank)
      end

      it { is_expected.to return_validation_errors :user_update }
    end
  end
end
