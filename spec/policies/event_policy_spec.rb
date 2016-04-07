require 'rails_helper'

RSpec.describe EventPolicy do
  subject { EventPolicy.new(user, event) }

  let(:event) { FactoryGirl.create(:event) }

  context 'being an unverified user' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to permit_action(:submit)        }
    it { is_expected.to forbid_action(:create)        }
    it { is_expected.to forbid_action(:update)        }
    it { is_expected.to forbid_action(:destroy)       }
    it { is_expected.to forbid_action(:submissions)   }

    it do
      is_expected.to have_authorization_error(:user_unverified, on: :create)
    end

    [:closed, :full].each do |type|
      context "when event is #{type}" do
        let(:event) { FactoryGirl.create(:"event_#{type}") }

        it { is_expected.to forbid_action(:submit)  }

        it do
          is_expected.to have_authorization_error(:"event_#{type}", on: :submit)
        end
      end
    end
  end

  context 'being a verified user' do
    let(:user) { FactoryGirl.create(:user_verified) }

    it { is_expected.to permit_action(:create) }
  end

  context 'being the event host' do
    let(:user) { event.host.user }

    it { is_expected.to permit_action(:update)        }
    it { is_expected.to permit_action(:destroy)       }
    it { is_expected.to permit_action(:submissions)   }
    it { is_expected.to forbid_action(:submit)        }

    context 'when event is closed' do
      let(:event) { FactoryGirl.create(:event_closed) }

      it { is_expected.to forbid_action(:update)  }
      it { is_expected.to forbid_action(:destroy) }

      it { is_expected.to have_authorization_error(:event_closed, on: :update)  }
      it { is_expected.to have_authorization_error(:event_closed, on: :destroy) }
    end
  end

  context 'being an event submitter' do
    let(:event) { FactoryGirl.create(:event_with_attendees) }

    let(:user) { event.attendees.first.user }

    it { is_expected.to forbid_action(:submit)        }
    it { is_expected.to forbid_action(:update)        }
    it { is_expected.to forbid_action(:destroy)       }
    it { is_expected.to forbid_action(:submissions)   }

    context 'after submission cancellation' do
      let(:submission) { user.submissions.find_by(event_id: event.id) }

      before { submission.destroy }

      it { is_expected.to permit_action(:submit) }
    end
  end
end
