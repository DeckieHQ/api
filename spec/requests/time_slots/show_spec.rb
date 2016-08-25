require 'rails_helper'

RSpec.describe 'Time slot show', :type => :request do
  let(:time_slot) { FactoryGirl.create(:time_slot) }

  before do
    get time_slot_path(time_slot), headers: json_headers
  end

  it { is_expected.to return_status_code 200 }

  it 'returns the time slot attributes' do
    expect(response.body).to equal_serialized(time_slot)
  end

  context "when time slot doesn't exist" do
    let(:time_slot) { { id: 0 } }

    it { is_expected.to return_not_found }
  end

  context 'when user is authenticated' do
    let(:authenticate) { FactoryGirl.create(:user) }

    it 'serializes the membership attribute to false' do
      expect(json_attributes[:member]).to be_falsy
    end

    context 'as a time slot member' do
      let(:time_slot) { FactoryGirl.create(:time_slot, :with_members) }

      let(:authenticate) { time_slot.members.shuffle.first.user }

      it 'serializes the membership attribute to true' do
        expect(json_attributes[:member]).to be_truthy
      end
    end
  end
end
