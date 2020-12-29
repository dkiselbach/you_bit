# frozen_string_literal: true

require 'rails_helper'

module Models
  RSpec.describe User, type: :model do
    let!(:user) { create_user_with_habits }

    it 'created user is sent welcome email' do
      password = Faker::Internet.password
      @user = described_class.new(name: Faker::Name.name, email: Faker::Internet.email,
                                  password: password, password_confirmation: password)

      expect { @user.save }
        .to have_enqueued_job.on_queue('YOUbit_development_default')
    end

    it 'delete user should delete habits' do
      expect { user.destroy }.to change(Habit, :count).by(-5)
    end

    it 'delete habit should delete logs' do
      create_habit_with_logs(5, user, user.habits.first)
      expect { described_class.first.destroy }.to change(HabitLog, :count).by(-5)
    end
  end
end
