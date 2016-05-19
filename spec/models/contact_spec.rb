require 'rails_helper'

RSpec.describe Contact, :type => :model do
  let(:user) { FactoryGirl.create(:user) }

  subject(:contact) { described_class.new(user) }

  it 'shares the user id' do
    expect(contact.id).to eq(user.id)
  end

  [:email, :phone_number].each do |attribute|
    it "delegates the user #{attribute}" do
      expect(contact.public_send(attribute)).to eq(user.public_send(attribute))
    end
  end
end
