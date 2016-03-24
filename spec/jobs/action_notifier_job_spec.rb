require 'rails_helper'

RSpec.describe ActionNotifierJob, :type => :job do
  subject(:perform) { described_class.perform_now(action) }

  let(:action) { FactoryGirl.create(:action, notify: :never) }

  xit do

  end
end
