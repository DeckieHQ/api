require 'rails_helper'

require 'base64'

RSpec.describe 'Profile update', :type => :request do
  let(:params) { Serialize.params(profile_update_params, type: :profiles) }

  let(:profile)               { FactoryGirl.create(:profile) }
  let(:profile_update)        { FactoryGirl.build(:profile) }
  let(:profile_update_params) { profile_update.attributes }

  let(:permited_params) do
    profile_update.slice(:nickname, :short_description, :description)
  end

  before do
    put profile_path(profile), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'with profile owner' do
      before { profile.reload }

      let(:authenticate) { profile.user }

      include_examples 'check parameters for', :profiles

      context 'when attributes are valid' do
        it { is_expected.to return_status_code 200 }

        it 'returns the profile attributes' do
          expect(response.body).to equal_serialized(profile)
        end

        it 'updates the profile with permited params' do
          expect(profile).to have_attributes(permited_params)
        end
      end

      context 'when attributes are not valid' do
        let(:profile_update) { FactoryGirl.build(:profile_invalid) }

        it { is_expected.to return_status_code 422 }
        it { is_expected.to return_validation_errors :profile_update }
      end

      describe 'Profile avatar update', :type => :upload do
        let(:profile_update_params) do
          encoded_file = Base64.encode64(
            File.open(Rails.root.join('spec/support/images/avatar.jpeg')).read
          )
          { avatar: "data:image/jpeg;base64,#{encoded_file}" }
        end

        it { is_expected.to return_status_code 200 }

        it 'uploads the avatar and stores the profile avatar url' do
          expect(profile.reload.avatar.url).to be_an_url
        end

        context 'when avatar is invalid' do
          let(:avatar) do
            "data:application/pdf;base64,/9j/4AAQSkZJRgABAQEASABKdhH//2Q=="
          end

          let(:profile_update_params) { { avatar: avatar } }

          let(:profile_update) { FactoryGirl.build(:profile, avatar: avatar) }

          it { is_expected.to return_status_code 422 }
          it { is_expected.to return_validation_errors :profile_update }
        end
      end
    end

    context 'with another user' do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it "doesn't update the profile" do
        expect(profile).to_not have_been_changed
      end
    end

    context "when profile doesn't exist" do
      let(:authenticate) { FactoryGirl.create(:user) }

      let(:profile) { { id: 0 } }

      it { is_expected.to return_not_found }
    end
  end
end
