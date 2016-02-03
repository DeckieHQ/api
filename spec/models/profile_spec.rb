require 'rails_helper'

RSpec.describe Profile, :type => :model do
  # Database
  it { is_expected.to have_db_index(:user_id).unique(true) }

  # Relations
  it { is_expected.to belong_to(:user) }

  # Validations
  it { is_expected.to validate_length_of(:nickname).is_at_most(64) }
end
