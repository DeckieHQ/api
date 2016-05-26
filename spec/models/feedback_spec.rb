require 'rails_helper'

RSpec.describe Feedback, :type => :model do
  describe 'Validations' do
    [:title, :description].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end

    {
      title:       128,
      description: 8192,
    }.each do |attribute, length|
      it { is_expected.to validate_length_of(attribute).is_at_most(length) }
    end
  end
end
