# frozen_string_literal: true

require 'rails_helper'

module Models
  RSpec.describe User, type: :model do
    let(:user) { create_user_with_habits }

    describe '.create' do
      context 'when created' do
        it 'is sent welcome email' do
          password = Faker::Internet.password
          @user = described_class.new(name: Faker::Name.name, email: Faker::Internet.email,
                                      password: password, password_confirmation: password)

          expect { @user.save }
            .to have_enqueued_job.on_queue('YOUbit_development_default')
        end
      end
    end

    describe '.destroy' do
      subject(:destroy_user) { user.destroy }

      context 'when has habits' do
        it 'destroys habits' do
          user
          expect { destroy_user }.to change(Habit, :count).by(-5)
        end
      end

      context 'when has habit logs through habits' do
        it 'destroys habit logs' do
          create_habit_with_logs(5, user.habits.first)
          expect { destroy_user }.to change(HabitLog, :count).by(-5)
        end
      end
    end

    context 'when has habits with categories' do
      it 'has categories through habits' do
        expect(user.categories.first).not_to be_nil
      end
    end
  end
end
