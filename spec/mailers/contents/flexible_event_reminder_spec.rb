require 'rails_helper'

RSpec.describe FlexibleEventReminder do
  let(:user) { event.host.user }

  let(:event) { FactoryGirl.create(:event, :flexible) }

  subject(:content) { described_class.new(user, event) }

  describe '#username' do
    subject { content.username }

    it { is_expected.to eq(user.email) }
  end

  describe '#subject' do
    subject { content.subject }

    it do
      is_expected.to eq(
        I18n.t('mailer.flexible_event_reminder.subject', title: event.title)
      )
    end
  end

  describe '#details' do
    subject { content.details }

    it do
      is_expected.to eq(
        I18n.t('mailer.flexible_event_reminder.subject', title: "<b>#{event.title}</b>")
      )
    end
  end

  describe '#event_url' do
    subject(:event_url) { content.event_url }

    it do
      is_expected.to equal_front_url_with("event/#{event.id}")
    end
  end
end
