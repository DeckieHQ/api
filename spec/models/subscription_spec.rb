require 'rails_helper'

RSpec.describe Subscription, :type => :model do
  it { is_expected.to have_db_index(:event_id) }
  it { is_expected.to have_db_index(:profile_id) }

  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:profile) }

  let(:subscription) { FactoryGirl.build(:subscription, status: status) }

  context 'when created' do
    context 'with a confirmed status' do
      let(:status) { :confirmed }

      it 'increases the event attendees_count' do
        expect_to_increase_counter_cache { subscription.save }
      end
    end

    context 'with another status' do
      let(:status) { :pending }

      it "doesn't change the event attendees_count" do
        expect_to_not_change_counter_cache { subscription.save }
      end
    end
  end

  context 'when updated' do
    context 'when pending' do
      let(:status) { :pending }

      before do
        subscription.save
      end

      context 'with a confirmed status' do
        it 'increases the event attendees_count' do
          expect_to_increase_counter_cache { subscription.confirmed! }
        end
      end

      context 'with a refused status' do
        it 'increases the event attendees_count' do
          expect_to_not_change_counter_cache { subscription.refused! }
        end
      end
    end

    context 'when confirmed' do
      let(:status) { :confirmed }

      before do
        subscription.save
      end

      context 'with a refused status' do
        it 'descreases the event attendees_count' do
          expect_to_decrease_counter_cache { subscription.refused! }
        end
      end
    end

    context 'when refused' do
      let(:status) { :refused }

      before do
        subscription.save
      end

      context 'with a confirmed status' do
        it 'increases the event attendees_count' do
          expect_to_increase_counter_cache { subscription.confirmed! }
        end
      end
    end
  end

  context 'when destroyed' do
    before do
      subscription.save
    end

    context 'when confirmed' do
      let(:status) { :confirmed }

      it 'descreases the event attendees_count' do
        expect_to_decrease_counter_cache { subscription.destroy }
      end
    end

    context 'when not confirmed' do
      let(:status) { :pending }

      it "doesn't change the event attendees_count" do
        expect_to_not_change_counter_cache { subscription.destroy }
      end
    end
  end

  def expect_to_increase_counter_cache(&action)
    expect_to_change_counter_cache_by(1, &action)
  end

  def expect_to_decrease_counter_cache(&action)
    expect_to_change_counter_cache_by(-1, &action)
  end

  def expect_to_change_counter_cache_by(value, &action)
    expect(action).to change { subscription.event.attendees_count }.by(value)
  end

  def expect_to_not_change_counter_cache(&action)
    expect(action).to_not change { subscription.event.attendees_count }
  end
end
