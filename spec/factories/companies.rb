# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    registration_number { Faker::Number.unique.number(digits: 10) }
  end
end
