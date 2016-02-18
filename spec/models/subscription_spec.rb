require 'rails_helper'

RSpec.describe Subscription, :type => :model do
  it { is_expected.to have_db_index(:event_id) }
  it { is_expected.to have_db_index(:profile_id) }

  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:profile) }
end
