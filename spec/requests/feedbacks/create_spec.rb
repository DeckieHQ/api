require 'rails_helper'

RSpec.describe 'Create feedback', :type => :request do
  let(:params)       { Serialize.params(feedback_params, type: :feedbacks) }

  let(:feedback_params) { feedback.instance_values }

  let(:feedback) { FactoryGirl.build(:feedback) }

  before do
    post feedbacks_path, params: params, headers: json_headers
  end

  after { MailDeliveries.clear }

  it { is_expected.to return_status_code(204) }

  it { is_expected.to have_sent_mail }

  context 'when user is authenticated' do
    let(:authenticate) { FactoryGirl.create(:user) }

    it { is_expected.to return_status_code(204) }

    it { expect(authenticate).to have_achievement('first-feedback') }

    it { is_expected.to have_sent_mail }
  end

  context 'when attributes are invalid' do
    let(:feedback) { Feedback.new }

    it { is_expected.to return_validation_errors :feedback }

    it { is_expected.to_not have_sent_mail }
  end
end
