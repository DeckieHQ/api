require 'rails_helper'

RSpec.describe RemindFlexibleEvents, type: :job do
  EMAIL_DELIVERY_TYPE = :flexible_event_reminder

  it 'uses the scheduler queue' do
    expect(described_class.queue_name).to eq('scheduler')
  end

  describe '#perform' do
    let!(:events) { FactoryGirl.create_list(:event, 5, :flexible) }

    let!(:confirmable) { FactoryGirl.create(:event_confirmable) }

    let!(:expected_mail) do
      UserMailer.public_send(EMAIL_DELIVERY_TYPE, confirmable.host.user, confirmable)
    end

    before { MailDeliveries.clear }

    context "when confirmable event host didn't receive a reminder" do
      before { described_class.perform_now }

      it 'sends a email reminder to the user' do
        expect(MailDeliveries.all).to equal_mails([expected_mail])
      end

      it 'creates a new email delivery' do
        expect(
          EmailDelivery.find_by(type: EMAIL_DELIVERY_TYPE, resource: confirmable)
        ).to be_present
      end
    end

    context "when confirmable event host already received a reminder" do
      before do
        confirmable.host.user.deliver_email(EMAIL_DELIVERY_TYPE, confirmable)

        described_class.perform_now
      end

      it "doesn't send an email reminder to the user" do
        expect(MailDeliveries.count).to eq(1)
      end

      it "doesn't create a new email delivery" do
        expect(
          EmailDelivery.where(type: EMAIL_DELIVERY_TYPE, resource: confirmable).count
        ).to eq(1)
      end
    end
  end
end
