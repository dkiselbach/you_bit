FactoryBot.define do
  factory :reminder do
    remind_at { Time.current + 2.hours }
    habit
  end
end
