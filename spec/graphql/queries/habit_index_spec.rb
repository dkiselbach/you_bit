# frozen_string_literal: true

require 'rails_helper'

module Queries
  RSpec.describe HabitIndex do
    describe '.index' do
      let(:user) { create_user_with_habits }
      let(:args) do
        { frequency: ['daily'], active: true }
      end

      let(:habits) { create_habit_with_logs(5, user.habits.first) }

      context 'when no params input' do
        it { expect(described_class.new(user).index.size).to eq(5) }
      end

      context 'when frequency is daily' do
        it { expect(described_class.new(user).index(frequency: args[:frequency]).size).to eq(5) }
      end

      context 'when active is true' do
        it 'returns active habits' do
          user.habits.first.toggle(:active).save
          habits = described_class.new(user).index(active: args[:active])
          expect(habits.size).to eq(4)
        end
      end

      context 'when active is false' do
        it 'returns inactive habits' do
          user.habits.first.toggle(:active).save
          args[:active] = false
          habits = described_class.new(user).index(active: args[:active])
          expect(habits.size).to eq(1)
        end
      end

      context 'when a certain day is input' do
        it 'returns habits on certain day' do
          user.habits.first.update(frequency: ['monday'])
          user.habits.last.update(frequency: ['tuesday'])
          args[:frequency] = ['monday']
          habits = described_class.new(user).index(active: args[:active], frequency: args[:frequency])
          expect(habits.size).to eq(4)
        end
      end
    end
  end
end
