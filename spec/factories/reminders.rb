# frozen_string_literal: true

FactoryBot.define do
  factory :reminder do
    remind_at { Time.current + 2.hours }
    time_zone { 'America/New_York' }
    habit
  end
end
