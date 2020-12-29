# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include GraphqlDevise::Concerns::Model
  after_create :send_welcome_email
  has_many :habits, dependent: :destroy
  has_many :habit_logs, dependent: :destroy

  private

  def send_welcome_email
    email = UserMailer.with(user: self).welcome_email.deliver_later
  end
end
