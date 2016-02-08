require 'rails_helper'

RSpec.describe Profile, :type => :model do
  # Database
  it { is_expected.to have_db_index(:user_id).unique(true) }

  # Relations
  it { is_expected.to belong_to(:user) }

  # Validations
  it { is_expected.to validate_length_of(:nickname).is_at_most(64) }
  it { is_expected.to validate_length_of(:short_description).is_at_most(140) }
  it { is_expected.to validate_length_of(:description).is_at_most(8192) }

  it { is_expected.to have_many(:subscriptions) }
  it { is_expected.to have_many(:hosted_events) }
  it { is_expected.to have_many(:attendance_events) }
end
