# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Habit, type: :model do
  let(:user) { create(:user) }

  it 'name must be less then 50 characters ' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 51), habit_type: 'goal',
                               frequency: 'daily', start_date: Time.now.utc)
    expect(habit.errors.messages[:name][0]).to eq('is too long (maximum is 50 characters)')
  end

  it 'must have start_date' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'goal',
                               frequency: 'daily')
    expect(habit.errors.messages[:start_date][0]).to eq("can't be blank")
  end

  it 'start_date must be valid date format' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'goal',
                               frequency: 'daily', start_date: 0)
    expect(habit.errors.messages[:start_date][0]).to eq('must be a valid date')
  end

  it 'habit_type should default to goal' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10),
                               frequency: 'daily', start_date: Time.now.utc)
    expect(habit.habit_type).to eq('goal')
  end

  it 'habit_type must be goal or limit' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'not limit',
                               frequency: 'daily', start_date: Time.now.utc)
    expect(habit.errors.messages[:habit_type][0]).to eq("Must be either 'goal' or 'limit'")
  end

  it 'frequency must be a valid frequency' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'limit',
                               frequency: 'hourly', start_date: Time.now.utc)
    expect(habit.errors.messages[:frequency][0]).to include('daily')
  end

  it 'active defaults to true if invalid boolean' do
    habit = user.habits.create(name: Faker::Alphanumeric.alpha(number: 10), habit_type: 'limit',
                               frequency: 'daily', active: 'not_a_boolean', start_date: Time.now.utc)
    expect(habit.active).to be_truthy
  end
end
