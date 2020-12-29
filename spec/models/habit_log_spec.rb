require 'rails_helper'

RSpec.describe HabitLog, type: :model do
  before do
    create_user_with_habits
  end

  it 'habit_type must be goal or limit' do
    habit_log = Habit.first.habit_logs.create(habit_type: 'aspiration', logged_date: Date.new)
    expect(habit_log.errors.messages[:habit_type][0]).to eq("Must be either 'goal' or 'limit'")
  end

  it 'logged_date must be valid date format' do
    habit_log = Habit.first.habit_logs.create(habit_type: 'goal', logged_date: "12/31/2020")
    expect(habit_log.errors.messages[:logged_date][0]).to eq('must be a valid date')
  end
end
