require 'rails_helper'

RSpec.describe Event, :type => :model do
  # Database
  it { is_expected.to have_db_index(:profile_id) }

  # Relations
  it { is_expected.to belong_to(:host) }

  it { is_expected.to have_many(:subscriptions) }
  it { is_expected.to have_many(:attendees) }
end
