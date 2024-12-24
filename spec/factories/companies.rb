# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    registration_number { Faker::Number.unique.number(digits: 10) }

    factory :company_with_addresses do
      transient do
        addresses_count { 2 }
      end

      addresses do
        Array.new(addresses_count) { association(:address) }
      end
    end
  end
end
