require 'rails_helper'

RSpec.describe Verification, :type => :model do
  it do
    is_expected.to validate_inclusion_of(:type).in_array(%w(email phone_number))
  end

  it { is_expected.to validate_presence_of(:token).on(:complete) }

  context 'when verification attributes are valid' do
    subject(:verification) { Verification.new(attributes, model: user) }

    [:email, :phone_number].each do |type|
      context "with type #{type}" do
        let(:user) do
          FactoryGirl.create(:"user_with_#{type}_verification")
        end

        let(:user_token) { user.send("#{type}_verification_token") }

        context 'when token equals the user token' do
          let(:attributes) do
            { type: type, token: user_token  }
          end

          it { is_expected.to be_valid(:complete) }

          context "when user's token has expired" do
            let(:user) do
              FactoryGirl.create(:"user_with_#{type}_verification_expired")
            end

            it { is_expected.to_not be_valid(:complete) }
          end
        end

        context 'when token differs from the user token' do
          let(:attributes) do
            { type: type, token: "#{user_token}." }
          end

          it { is_expected.to_not be_valid(:complete) }
        end
      end
    end
  end
end
