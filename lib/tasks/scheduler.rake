# frozen_string_literal: true

desc 'This task is called by the Heroku scheduler add-on'

task schedule_reminders: :environment do
  Reminder.schedule_all
end
