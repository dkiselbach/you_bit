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
    let(:time) { Time.new('2021', '02', '01', 0, 0, 0).utc } # Date is a Monday

    before do
      create(:device, user: user)
      allow(Time).to receive(:now).and_return(time)
    end

    context 'when habit frequency is daily' do
      it 'enqueues 1 reminder' do
        expect { reminder }.to enqueue_job(PushNotificationJob).at_least(1).times
      end

      it 'does not enqueue reminder if reminder time is in the past' do
        args[:remind_at] = Time.now.utc - 1.minute
        expect { reminder }.not_to enqueue_job(PushNotificationJob)
      end
    end

    context 'when habit frequency is one day' do
      before do
        user.habits.first.update(frequency: ['monday'])
      end

      it 'enqueues 1 reminder if on correct day' do
        expect { reminder }.to enqueue_job(PushNotificationJob).at_least(1).times
      end

      it 'does not enqueue reminder if not on correct day' do
        user.habits.first.update(frequency: ['tuesday'])
        expect { reminder }.not_to enqueue_job(PushNotificationJob)
      end
    end

    context 'when habit frequency is two days' do
      it 'enqueues 1 reminder if on first correct day' do
        user.habits.first.update(frequency: %w[monday tuesday])
        expect { reminder }.to enqueue_job(PushNotificationJob).at_least(1).times
      end

      it 'does not enqueue reminder if not on correct day' do
        user.habits.first.update(frequency: %w[tuesday wednesday])
        expect { reminder }.not_to enqueue_job(PushNotificationJob)
      end
    end

    context 'when user has multiple devices' do
      before do
        create_list(:device, 2, user: user)
      end

      it 'enqueues a reminder for each device' do
        expect { reminder }.to enqueue_job(PushNotificationJob).at_least(3).times
      end
    end
  end
end
