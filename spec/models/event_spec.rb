require 'rails_helper'

RSpec.describe Event, :type => :model do
  # Database
  it { is_expected.to have_db_index(:profile_id) }

  # Relations
  it { is_expected.to belong_to(:host) }

  it { is_expected.to have_many(:subscriptions) }
  it { is_expected.to have_many(:attendees) }

  # Validations
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(128) }

  it { is_expected.to validate_presence_of(:begin_at) }

  it do
    is_expected.to validate_date_before(:begin_at, { limit: Time.now, on: :second })
  end

  it { is_expected.to validate_presence_of(:end_at) }

  it do
    is_expected.to validate_date_after(:end_at, { limit: :begin_at , on: :second })
  end
end
