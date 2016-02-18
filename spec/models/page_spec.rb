require 'rails_helper'

RSpec.describe Page, :type => :model do
  describe 'Validations' do
    # Skip these tests until should-matchers is fixed...
    # Issue: https://github.com/thoughtbot/shoulda-matchers/issues/784
    xit do
      is_expected.to validate_numericality_of(:number).is_greater_than(0)
    end

    xit do
      is_expected.to validate_numericality_of(:size)
        .is_greater_than(0)
        .is_less_than_or_equal_to(50)
    end

    context 'when attributes is not a hash' do
      subject(:page) { Page.new('whatever') }

      it { is_expected.to_not be_valid }
    end
  end

  describe '#params' do
    subject(:page) { FactoryGirl.build(:page) }

    it 'formats page to pagination parameters' do
      expect(page.params).to eql({ page: page.number, per_page: page.size })
    end
  end
end
