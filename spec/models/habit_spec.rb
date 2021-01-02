# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Habit, type: :model do
  let(:user) { create_user_with_habits(habits_count: 1) }

  let(:generate_habit_log_dates) do
    %w[2020-12-29 2020-12-30 2020-12-31 2021-01-01 2021-01-02].each do |date|
      FactoryBot.create(:habit_log, logged_date: date, habit: user.habits.first)
    end
  end

  describe '.valid?' do
    context 'when name is invalid' do
      it 'validates length' do
        habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 51), habit_type: 'goal',
                                   frequency: ['daily'], start_date: Time.now.utc)
        expect(habit.errors.messages[:name][0]).to eq('is too long (maximum is 50 characters)')
      end
    end

    context 'when start_date is missing' do
      it 'validates presence' do
        habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'goal',
                                   frequency: ['daily'])
        expect(habit.errors.messages[:start_date][1]).to eq("can't be blank")
      end
    end

    context 'when category_name is invalid' do
      it 'validates presence' do
        habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'goal',
                                   frequency: ['daily'], start_date: Time.now.utc)
        expect(habit.errors.messages[:category_name][0]).to eq("can't be blank")
      end

      it 'validates length' do
        habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'goal',
                                   frequency: ['daily'], start_date: Time.now.utc,
                                   category_name: Faker::Alphanumeric.alpha(number: 101))
        expect(habit.errors.messages[:category_name][0]).to eq('is too long (maximum is 100 characters)')
      end
    end

    context 'when start_date is invalid' do
      it 'validates date format' do
        habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'goal',
                                   frequency: ['daily'], start_date: '12/31/2020')
        expect(habit.errors.messages[:start_date][0]).to eq('must be a valid date')
      end
    end

    context 'when habit_type is missing' do
      it 'defaults to goal' do
        habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10),
                                   frequency: ['daily'], start_date: Time.now.utc)
        expect(habit.habit_type).to eq('goal')
      end
    end

    context 'when habit_type is invalid' do
      it "validates 'goal' or 'limit'" do
        habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'not limit',
                                   frequency: ['daily'], start_date: Time.now.utc)
        expect(habit.errors.messages[:habit_type][0]).to eq("Must be either 'goal' or 'limit'")
      end
    end

    context 'when frequency is invalid' do
      it 'validates frequency' do
        habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'limit',
                                   frequency: ['hourly'], start_date: Time.now.utc)
        expect(habit.errors.messages[:frequency][0]).to include('daily')
      end
    end
  end

  describe '.active' do
    it 'sorts by active' do
      create_list(:habit, 4, user: user)
      expect(user.habits.active.size).to be(5)
    end
  end

  describe '.inactive' do
    it 'sorts by inactive' do
      user.habits.first.toggle(:active).save
      expect(user.habits.inactive.size).to be(1)
    end
  end

  describe '.with_certain_dates' do
    it 'sorts by input days' do
      create_list(:habit, 4, user: user)
      certain_days = %w[monday daily]
      user.habits.first.update(frequency: ['monday'])
      user.habits.second.update(frequency: ['tuesday'])
      expect(user.habits.with_certain_days(certain_days).size).to be(4)
    end
  end

  describe '.destroy' do
    context 'when has logs' do
      it 'deletes associated logs' do
        generate_habit_log_dates
        expect { described_class.first.destroy }.to change(HabitLog, :count).by(-5)
      end
    end
  end

  describe '.logged?' do
    context 'when habit is logged' do
      it 'returns true' do
        habit = user.habits.first
        create_habit_with_logs(1, habit)
        be_logged = habit.logged?('2020-12-28')
        expect(be_logged).to be_truthy
      end
    end

    context 'when habit is not logged' do
      it 'returns false' do
        habit = user.habits.first
        create_habit_with_logs(1, habit)
        be_logged = habit.logged?('2020-12-27')
        expect(be_logged).to be_falsey
      end
    end
  end

  describe '.logged' do
    context 'when habit is logged' do
      it 'returns hash' do
        habit = user.habits.first
        create_habit_with_logs(1, habit)
        be_logged = habit.logged('2020-12-28')
        expect(be_logged[:habit_log].id).to eq(habit.habit_logs.last.id)
      end
    end

    context 'when habit is not logged' do
      it 'returns nil' do
        habit = user.habits.first
        create_habit_with_logs(1, habit)
        be_logged = habit.logged('2020-12-27')
        expect(be_logged[:habit_log]).to be_nil
      end
    end
  end

  describe '.current_streak' do
    it 'returns correct streak' do
      date = generate_habit_log_dates.third
      habit_streak = user.habits.first.current_streak(date)['habit_streak']
      expect(habit_streak).to eq(3)
    end
  end

  describe '.longest_streak' do
    it 'returns correct streak' do
      generate_habit_log_dates
      habit_streak = user.habits.first.longest_streak['habit_streak']
      expect(habit_streak).to eq(5)
    end
  end

  describe '.create' do
    subject(:create_habit) { create(:habit, category_name: 'Foo', active: 'not_a_boolean') }

    context 'when category does not exist' do
      it 'creates a category' do
        expect { create_habit }.to change(Category, :count).by(1)
      end
    end

    context 'when category does exist' do
      it 'uses category' do
        Category.create(name: 'Foo')
        expect { create_habit }.not_to change(Category, :count)
      end
    end

    context 'when active is invalid' do
      it { expect(create_habit.active).to be_truthy }
    end
  end
end
