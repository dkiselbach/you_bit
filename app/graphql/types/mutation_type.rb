# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    include GraphqlDevise::Concerns::ControllerMethods
    field :create_habit, mutation: Mutations::CreateHabit, authenticate: true
    field :destroy_habit, mutation: Mutations::DestroyHabit, authenticate: true
    field :update_habit, mutation: Mutations::UpdateHabit, authenticate: true
    field :create_habit_log, mutation: Mutations::CreateHabitLog, authenticate: true
    field :destroy_habit_log, mutation: Mutations::DestroyHabitLog, authenticate: true
    field :create_device, mutation: Mutations::CreateDevice, authenticate: true
    field :destroy_device, mutation: Mutations::DestroyDevice, authenticate: true
    field :create_reminder, mutation: Mutations::CreateReminder, authenticate: true
  end
end
