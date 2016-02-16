require 'rails_helper'

RSpec.describe UserSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:user) { FactoryGirl.create(:user) }

    let(:serialized) do
      Serialized.new(UserSerializer.new(user))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        user.slice(:first_name, :last_name, :birthday, :email, :phone_number, :culture)
      )
    end
  end
end
