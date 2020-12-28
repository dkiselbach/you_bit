# frozen_string_literal: true

require 'rails_helper'

module Queries
  RSpec.describe HabitIndex do
    describe '.index_by' do
      let(:user) { user_with_habits }
      let(:args) do
        { frequency: ['daily'], active: true }
      end

      it 'returns daily habits' do
        user.habits.first.update(frequency: ['monday'])
        habits = described_class.new(user).index_by(args[:active], args[:frequency])
        expect(habits.size).to eq(4)
      end

      it 'returns active habits' do
        user.habits.first.toggle(:active).save
        habits = described_class.new(user).index_by(args[:active], args[:frequency])
        expect(habits.size).to eq(4)
      end

      it 'returns inactive habits' do
        user.habits.first.toggle(:active).save
        args[:active] = false
        habits = described_class.new(user).index_by(args[:active], args[:frequency])
        expect(habits.size).to eq(1)
      end

      it 'returns habits on a certain day' do
        user.habits.first.update(frequency: ['monday'])
        user.habits.last.update(frequency: ['tuesday'])
        args[:frequency] = ['monday']
        habits = described_class.new(user).index_by(args[:active], args[:frequency])
        expect(habits.size).to eq(4)
      end
    end
  end
end
