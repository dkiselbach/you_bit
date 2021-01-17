# frozen_string_literal: true

require 'rails_helper'
require_relative 'validatable'

module Validators
  RSpec.describe TimeZoneValidator do
    let(:object) { Validatable.new }

    describe 'invalid time zone' do
      ['pst', 'est', 'hi', ' '].each do |time_zone|
        context "when time zone is #{time_zone}" do
          it 'adds an error' do
            object.time_zone = time_zone
            object.valid?
            expect(object.errors[:time_zone][0]).to eq('must be a valid time zone')
          end
        end
      end
    end

    describe 'valid time zone' do
      %w[Pacific/Fiji Africa/Casablanca].each do |time_zone|
        context "when time zone is #{time_zone}" do
          it 'does not add an error' do
            object.time_zone = time_zone
            object.valid?
            expect(object.errors[:time_zone][0]).not_to eq('must be a valid time zone')
          end
        end
      end
    end
  end
end
