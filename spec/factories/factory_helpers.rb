# frozen_string_literal: true

def user_with_habits(habits_count: 5)
  FactoryBot.create(:user) do |user|
    FactoryBot.create_list(:habit, habits_count, user: user)
  end
end
