require 'rails_helper'

RSpec.describe ContactPolicy do
  let(:user) { FactoryGirl.create(:user) }

  let(:contact) { Contact.new(FactoryGirl.create(:user)) }

  subject { described_class.new(user, contact) }

  it { is_expected.to forbid_action(:show) }

  context 'when user attends an event of the contact user' do
    before do
      allow(contact.user).to receive(:host_of?).and_return(true)
    end

    it { is_expected.to permit_action(:show) }
  end

  context 'when user is the host of an event that the contact user attends' do
    before do
      allow(user).to receive(:host_of?).and_return(true)
    end

    it { is_expected.to permit_action(:show) }
  end
end
