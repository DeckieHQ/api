require 'rails_helper'

RSpec.describe CompleteVerification do
  let(:service) { CompleteVerification.new(user, verification) }

  describe '#call' do
    subject(:call) { service.call }

    [:email, :phone_number].each do |type|
      verify = :"verify_#{type}!"

      context "when verification type is #{type}" do
        let(:user) { FactoryGirl.create(:"user_with_#{type}_verification") }

        let(:verification) { Verification.new({ type: type }, model: user) }

        before do
          allow(user).to receive(verify).and_return(true)

          call
        end

        it 'returns the user' do
          is_expected.to eq(user)
        end

        it "verifies the model #{type}"  do
          expect(user).to have_received(verify)
        end
      end
    end
  end
end
