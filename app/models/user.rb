# frozen_string_literal: true

# Class responsible for managing users
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include GraphqlDevise::Concerns::Model
  after_create :send_welcome_email
  has_many :habits, dependent: :destroy
  has_many :categories, through: :habits
  has_many :devices, dependent: :destroy

  private

  def send_welcome_email
    UserMailer.with(user: self).welcome_email.deliver_later
  end
end
