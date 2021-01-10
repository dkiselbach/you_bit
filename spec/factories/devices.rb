FactoryBot.define do
  factory :device do
    token { Faker::Internet.uuid }
    platform { 'iOS' }
    client_identifier { 'My iPhone' }
    user
  end
end
