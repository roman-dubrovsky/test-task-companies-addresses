# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    company

    street { Faker::Address.street_name }
    city { Faker::Address.city }
    postal_code { Faker::Address.zip_code }
    country { Faker::Address.country }
  end
end
