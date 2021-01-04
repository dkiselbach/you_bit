module GraphQlMixins
  # Helper methods for habits within graphql
  module Habit
    private

    def user_has_access_to_habit(habit:)
      habit.user_id == current_resource.id
    end
  end
end
