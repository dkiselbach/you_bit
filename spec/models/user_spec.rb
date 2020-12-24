# frozen_string_literal: true

require 'rails_helper'

module Models
  RSpec.describe User, type: :model do
    it 'created user is sent welcome email' do
      password = Faker::Internet.password
      @user = described_class.new(name: Faker::Name.name, email: Faker::Internet.email,
                                  password: password, password_confirmation: password)

      expect { @user.save }
        .to have_enqueued_job.on_queue('YOUbit_development_default')
    end
  end
end
