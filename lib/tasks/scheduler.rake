desc 'This task is called by the Heroku scheduler add-on'

task schedule_reminders: :environment do
  Reminder.schedule_all
end
