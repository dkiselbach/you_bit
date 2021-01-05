module GraphQlMixins
  # Helper methods for habits within graphql
  module HabitHelpers
    extend ActiveSupport::Concern

    private

    def find_habit_in_user_context(habit_id:)
      habit = Habit.find(habit_id)

      unless user_has_access_to_habit(habit: habit)
        raise Errors::ForbiddenError.new('User does not have access to the Habit',
                                         errors: I18n.t('graphql_devise.errors.bad_id'))
      end
      habit
    end

    def user_has_access_to_habit(habit:)
      habit.user_id == current_resource.id
    end
  end
end
