FactoryBot.define do
  factory :habit_log do
    logged_date { '2020-12-28' }
    habit_type { 'goal' }
    habit
  end
end
