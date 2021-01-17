# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reminder, type: :model do
  include_context 'shared methods'
  let(:reminder) { described_class.create(**args) }

  let(:args) { { habit: user.habits.first, remind_at: (Time.current + 2.hours).to_s, time_zone: 'America/New_York' } }

  describe 'valid?' do
    subject(:reminder_errors) { reminder.errors.messages }

    context 'when params are not present' do
      let(:args) { { habit: user.habits.first, remind_at: nil, time_zone: nil } }

      it { expect(reminder_errors[:remind_at][1]).to eq("can't be blank") }

      it { expect(reminder_errors[:time_zone][1]).to eq("can't be blank") }
    end

    context 'when params are invalid' do
      let(:args) { { habit: user.habits.first, remind_at: 'A far away time', time_zone: 'A far away time zone' } }

      it { expect(reminder_errors[:remind_at][0]).to eq('must be a valid date') }

      it { expect(reminder_errors[:time_zone][0]).to eq('must be a valid time zone') }
    end
  end

  describe '.enqueue_reminders' do
    before do
      create(:device, user: user)
    end

    context 'when habit frequency is daily' do
      it 'enqueues 7 reminders' do
        expect { reminder }.to enqueue_job(PushNotificationJob).at_least(7).times
      end
    end

    context 'when habit frequency is one day' do
      it 'enqueues 1 reminder' do
        user.habits.first.update(frequency: ['monday'])
        expect { reminder }.to enqueue_job(PushNotificationJob).at_least(1).times
      end
    end

    context 'when habit frequency is two days' do
      it 'enqueues 2 reminders' do
        user.habits.first.update(frequency: %w[monday tuesday])
        expect { reminder }.to enqueue_job(PushNotificationJob).at_least(2).times
      end
    end
  end

  describe '.next_reminder' do
    context 'when input is 7 days' do
      it 'returns remind_at in 7 days' do
        Time.zone = 'America/New_York'
        time = Time.current
        future_time = time + 7.days
        args[:remind_at] = time
        expect(reminder.next_reminder(days: 7)).to eq(Time.zone.local(future_time.year, future_time.month, future_time.day, future_time.hour, future_time.min, future_time.sec))
      end
    end

    context 'when input is 1 day' do
      it 'returns remind_at in 1 days' do
        Time.zone = 'America/New_York'
        time = Time.current
        future_time = time + 1.day
        args[:remind_at] = time
        expect(reminder.next_reminder(days: 1)).to eq(Time.zone.local(future_time.year, future_time.month, future_time.day, future_time.hour, future_time.min, future_time.sec))
      end
    end
  end
end
