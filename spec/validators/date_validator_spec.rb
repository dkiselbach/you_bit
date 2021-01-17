# frozen_string_literal: true

require 'rails_helper'
require_relative 'validatable'

module Validators
  RSpec.describe DateValidator do
    let(:object) { Validatable.new }

    describe 'invalid date' do
      [0, '12/31/2020', 'hi', ' '].each do |date|
        context "when date is #{date}" do
          it 'adds an error' do
            object.date = date
            object.valid?
            expect(object.errors[:date][0]).to eq('must be a valid date')
          end
        end
      end
    end

    describe 'valid date' do
      [Date.new, '2020/12/31'].each do |date|
        context "when date is #{date}" do
          it 'does not add an error' do
            object.date = date
            object.valid?
            expect(object.errors[:date][0]).not_to eq('must be a valid date')
          end
        end
      end
    end
  end
end
