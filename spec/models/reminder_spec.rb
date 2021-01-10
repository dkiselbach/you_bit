require 'rails_helper'

RSpec.describe Reminder, type: :model do
  include_context 'shared methods'
  let(:args) { { habit: user.habits.first, remind_at: (Time.current + 2.hours).to_s } }

  describe 'valid?' do
    subject(:reminder_errors) { described_class.create(**args).errors.messages }

    context 'when token is not present' do
      it 'validates presence' do
        args[:remind_at] = nil
        expect(reminder_errors[:remind_at][1]).to eq("can't be blank")
      end
    end

    context 'when remind_at is invalid' do
      it 'validates time format' do
        args[:remind_at] = 'A far away time'
        expect(reminder_errors[:remind_at][0]).to eq('must be a valid date')
      end
    end
  end
end
