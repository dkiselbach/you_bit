# README

This is the Rails API for the mobile app YOUbit.

## Setting up your local DB

Once you have your PG server online, run the following migration command:

`RAILS_ENV=test rails db:migrate && RAILS_ENV=development rails db:migrate`