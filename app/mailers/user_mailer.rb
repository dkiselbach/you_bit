# frozen_string_literal: true

# Class for handling mail about the users account
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to YOUbit')
  end
end
