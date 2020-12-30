# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Habit, type: :model do
  let!(:user) { create_user_with_habits }

  before do
    %w[2020-12-29 2020-12-30 2020-12-31 2021-01-01 2021-01-02].each do |date|
      FactoryBot.create(:habit_log, logged_date: date, habit: user.habits.first)
    end
  end

  it 'name must be less then 50 characters ' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 51), habit_type: 'goal',
                               frequency: ['daily'], start_date: Time.now.utc)
    expect(habit.errors.messages[:name][0]).to eq('is too long (maximum is 50 characters)')
  end

  it 'must have start_date' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'goal',
                               frequency: ['daily'])
    expect(habit.errors.messages[:start_date][1]).to eq("can't be blank")
  end

  it 'start_date must be valid date format' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'goal',
                               frequency: ['daily'], start_date: '12/31/2020')
    expect(habit.errors.messages[:start_date][0]).to eq('must be a valid date')
  end

  it 'habit_type should default to goal' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10),
                               frequency: ['daily'], start_date: Time.now.utc)
    expect(habit.habit_type).to eq('goal')
  end

  it 'habit_type must be goal or limit' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'not limit',
                               frequency: ['daily'], start_date: Time.now.utc)
    expect(habit.errors.messages[:habit_type][0]).to eq("Must be either 'goal' or 'limit'")
  end

  it 'frequency must be a valid frequency' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'limit',
                               frequency: ['hourly'], start_date: Time.now.utc)
    expect(habit.errors.messages[:frequency][0]).to include('daily')
  end

  it 'active defaults to true if invalid boolean' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'limit',
                               frequency: ['daily'], active: 'not_a_boolean', start_date: Time.now.utc)
    expect(habit.active).to be_truthy
  end

  it 'active scope sorts by active' do
    expect(user.habits.active.size).to be(5)
  end

  it 'active scope sorts by inactive' do
    user.habits.first.toggle(:active).save
    expect(user.habits.inactive.size).to be(1)
  end

  it 'active scope sorts by with_certain_days' do
    certain_days = %w[monday daily]
    user.habits.first.update(frequency: ['monday'])
    user.habits.second.update(frequency: ['tuesday'])
    expect(user.habits.with_certain_days(certain_days).size).to be(4)
  end

  it 'delete habit should delete logs' do
    expect { described_class.first.destroy }.to change(HabitLog, :count).by(-5)
  end

  it 'logged? returns true for logged habit' do
    habit = user.habits.first
    create_habit_with_logs(1, habit)
    be_logged = habit.logged?('2020-12-28')
    expect(be_logged).to be_truthy
  end

  it 'logged? returns false for logged habit' do
    habit = user.habits.first
    create_habit_with_logs(1, habit)
    be_logged = habit.logged?('2020-12-27')
    expect(be_logged).to be_falsey
  end

  it 'current_streak returns correct streak' do
    habit_streak = user.habits.first.current_streak('2020-12-31')['habit_streak']
    expect(habit_streak).to eq(3)
  end

  it 'longest_streak returns correct streak' do
    habit_streak = user.habits.first.longest_streak['habit_streak']
    expect(habit_streak).to eq(5)
  end
end
