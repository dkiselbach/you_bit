require 'rails_helper'

RSpec.describe HabitLog, type: :model do
  let(:user) { create_user_with_habits(habits_count: 1) }

  describe 'valid?' do
    context 'when habit_type is invalid' do
      it 'validates input' do
        habit_log = user.habits.first.habit_logs.create(habit_type: 'aspiration', logged_date: Date.new)
        expect(habit_log.errors.messages[:habit_type][0]).to eq("Must be either 'goal' or 'limit'")
      end
    end

    context 'when logged_date is invalid' do
      it 'validates date format' do
        habit_log = user.habits.first.habit_logs.create(habit_type: 'goal', logged_date: '12/31/2020')
        expect(habit_log.errors.messages[:logged_date][0]).to eq('must be a valid date')
      end
    end
  end

  describe '.most_recent' do
    it 'returns most recent log' do
      habit_log = user.habits.first.habit_logs.create(habit_type: 'goal', logged_date: Time.zone.today)
      expect(Habit.first.habit_logs.most_recent.logged_date).to eq(habit_log.logged_date)
    end
  end
end
