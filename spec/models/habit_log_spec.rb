# frozen_string_literal: true

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

  describe 'after_create' do
    context 'when habit is goal and frequency is daily' do
      before do
        (0..4).to_a.reverse_each do |day|
          user.habits.first.habit_logs.create(habit_type: 'goal', logged_date: Date.current - day)
        end
      end

      it 'logs current habit streak' do
        expect(described_class.most_recent.current_streak).to eq(5)
      end
    end

    context 'when habit is goal and frequency is not daily' do
      before do
        last_monday = Date.new(2021, 1, 25)
        last_wednesday = Date.new(2021, 1, 27)
        last_thursday = Date.new(2021, 1, 28)
        this_monday = Date.new(2021, 2, 1)
        user.habits.first.update(frequency: %w[monday wednesday thursday])
        user.habits.first.habit_logs.create(habit_type: 'goal', logged_date: last_monday)
        user.habits.first.habit_logs.create(habit_type: 'goal', logged_date: last_wednesday)
        user.habits.first.habit_logs.create(habit_type: 'goal', logged_date: last_thursday)
        user.habits.first.habit_logs.create(habit_type: 'goal', logged_date: this_monday)
      end

      it 'logs current habit streak' do
        expect(described_class.most_recent.current_streak).to eq(4)
      end
    end

    context 'when habit is limit' do
      before do
        (0..5).to_a.reverse_each do |day|
          user.habits.first.habit_logs.create(habit_type: 'limit', logged_date: Date.new - day)
        end
      end

      it 'does not log current streak' do
        expect(described_class.most_recent.current_streak).to be_nil
      end
    end
  end
end
