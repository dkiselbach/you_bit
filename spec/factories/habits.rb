FactoryBot.define do
  factory :habit do
    name { Faker::Company.bs }
    description { Faker::Quote.yoda }
    habit_type { 'goal' }
    frequency { ['daily'] }
    start_date { Date.new.to_s }
    category_name { Faker::Quote.singular_siegler }
    user
  end
end
