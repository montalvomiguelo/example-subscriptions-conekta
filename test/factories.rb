FactoryBot.define do
  to_create { |instance| instance.save }

  factory :product
  factory :user
end
