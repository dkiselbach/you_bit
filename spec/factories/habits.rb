FactoryBot.define do
  factory :habit do
    name { Faker::Company.bs }
    description { Faker::Quote.yoda }
    habit_type { "goal" }
    frequency { "daily" }
    start_date { Time.now }
  end
end
