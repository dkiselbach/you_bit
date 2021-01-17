# frozen_string_literal: true

RSpec.shared_context 'shared methods', shared_context: :metadata do
  subject(:error_code) { JSON.parse(response.body).dig('errors', 0, 'extensions', 'code') }

  let(:user) { create_user_with_habits }
  let(:auth_headers) { user.create_new_auth_token }
  let(:forbidden_user) { create(:user) }
  let(:forbidden_auth_headers) { forbidden_user.create_new_auth_token }
  let(:habits) { create_habit_with_logs(5, user.habits.first) }
end

RSpec.configure do |rspec|
  rspec.include_context 'shared methods', include_shared: true
end
