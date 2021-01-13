require 'rails_helper'

RSpec.describe Reminder, type: :model do
  include_context 'shared methods'

  describe 'valid?' do
    subject(:reminder_errors) { described_class.create(**args).errors.messages }
    let(:args) { { habit: user.habits.first, remind_at: (Time.current + 2.hours).to_s, time_zone: 'Pacific/Fiji' } }

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
end
