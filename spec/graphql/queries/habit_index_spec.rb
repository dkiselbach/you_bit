# frozen_string_literal: true

require 'rails_helper'

module Queries
  RSpec.describe HabitIndex do
    describe '.index_by' do
      let!(:user) { create_user_with_habits }
      let(:args) do
        { frequency: ['daily'], active: true }
      end

      before do
        create_habit_with_logs(5, user.habits.first)
      end

      it 'returns all habits by default' do
        habits = described_class.new(user).index
        expect(habits.size).to eq(5)
      end

      it 'returns daily habits only' do
        user.habits.first.update(frequency: ['monday'])
        habits = described_class.new(user).index(args[:active], args[:frequency])
        expect(habits.size).to eq(4)
      end

      it 'returns active habits' do
        user.habits.first.toggle(:active).save
        habits = described_class.new(user).index(args[:active], args[:frequency])
        expect(habits.size).to eq(4)
      end

      it 'returns inactive habits' do
        user.habits.first.toggle(:active).save
        args[:active] = false
        habits = described_class.new(user).index(args[:active], args[:frequency])
        expect(habits.size).to eq(1)
      end

      it 'returns habits on a certain day only' do
        user.habits.first.update(frequency: ['monday'])
        user.habits.last.update(frequency: ['tuesday'])
        args[:frequency] = ['monday']
        habits = described_class.new(user).index(args[:active], args[:frequency])
        expect(habits.size).to eq(4)
      end
    end
  end
end
