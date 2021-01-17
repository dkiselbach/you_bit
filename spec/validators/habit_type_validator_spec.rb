# frozen_string_literal: true

require 'rails_helper'
require_relative 'validatable'

module Validators
  RSpec.describe HabitTypeValidator do
    let(:object) { Validatable.new }

    describe 'invalid habit type' do
      [0, 'aspiration', ' '].each do |type|
        context "when habit type is #{type}" do
          it 'adds an error' do
            object.habit_type = type
            object.valid?
            expect(object.errors[:habit_type][0]).to eq("Must be either 'goal' or 'limit'")
          end
        end
      end
    end

    describe 'valid habit type' do
      %w[goal limit].each do |type|
        context "when habit type is #{type}" do
          it 'does not add an error' do
            object.habit_type = type
            object.valid?
            expect(object.errors[:habit_type][0]).not_to eq("Must be either 'goal' or 'limit'")
          end
        end
      end
    end
  end
end
