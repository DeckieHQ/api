require 'rails_helper'

RSpec.describe UserMailer do
  describe '#reset_password_instructions' do
    let(:user) { FactoryGirl.create(:user)  }

    let(:reset_password_token) { user.send(:set_reset_password_token) }

    let(:mail) { UserMailer.reset_password_instructions(user, reset_password_token) }

    it 'renders the subject' do
      expect(mail.subject).to eq(
        I18n.t('devise.mailer.reset_password_instructions.subject')
      )
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq [user.email]
    end

    it 'renders the sender email' do
      expect(mail.from).to eq ['notifications@deckie.io']
    end

    it 'renders the reply to email' do
      expect(mail.reply_to).to eq ['notifications@deckie.io']
    end

    it 'assigns @user.email' do
      expect(mail.body.encoded).to match(user.email)
    end

    it 'assigns @reset_password_url' do
      reset_password_url = users_reset_password_url
      reset_password_url << "/edit?reset_password_token=#{reset_password_token}"

      expect(mail.body.encoded).to include(reset_password_url)
    end
  end
end
