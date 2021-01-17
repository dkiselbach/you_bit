# frozen_string_literal: true

def create_user_with_habits(habits_count: 5)
  FactoryBot.create(:user) do |user|
    FactoryBot.create(:category) do |category|
      FactoryBot.create_list(:habit, habits_count, user: user, category: category)
    end
  end
end

def create_habit_with_logs(logs_count, habit)
  FactoryBot.create_list(:habit_log, logs_count, habit: habit)
end
