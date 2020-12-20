# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail = mail(to: @user.email, subject: 'Welcome to YOUbit')
  end
end
