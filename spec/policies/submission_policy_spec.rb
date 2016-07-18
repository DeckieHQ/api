require 'rails_helper'

RSpec.describe SubmissionPolicy do
  subject { described_class.new(user, submission) }

  let(:submission) { FactoryGirl.create(:submission, :pending) }

  context 'being a visitor' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:show)    }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:confirm) }
  end

  context 'being the submission event host' do
    let(:user) { submission.event.host.user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:confirm) }

    [:closed, :full].each do |type|
      context "when submission event is #{type}" do
        let(:submission) do
          FactoryGirl.create(:submission, :pending, :"to_event_#{type}")
        end

        it { is_expected.to forbid_action(:confirm)  }

        it do
          is_expected.to have_authorization_error(:"event_#{type}", on: :confirm)
        end
      end
    end

    context 'when submission is already confirmed' do
      let(:submission) { FactoryGirl.create(:submission, :confirmed) }

      it { is_expected.to forbid_action(:confirm) }

      it do
        is_expected.to have_authorization_error(
          :submission_already_confirmed, on: :confirm
        )
      end
    end
  end

  context 'being the subscribtion owner' do
    let(:user) { submission.profile.user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to forbid_action(:confirm) }

    context 'when submission event is closed' do
      let(:submission) do
        FactoryGirl.create(:submission, :to_event_closed)
      end

      it { is_expected.to forbid_action(:destroy) }

      it { is_expected.to have_authorization_error(:event_closed, on: :destroy) }
    end
  end
end
