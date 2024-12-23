# frozen_string_literal: true

class CompanyContract < ApplicationContract
  params do
    required(:name).filled(:string)
    required(:registration_number).value(:integer)

    required(:addresses).array(:hash) do
      required(:city).filled(:string)
      required(:street).filled(:string)
      required(:country).filled(:string)
      optional(:postal_code).filled(:string)
    end
  end

  rule(:name) do
    key.failure("must be at most 256 characters") if value.length > 256
  end

  rule(:registration_number) do
    key.failure("must be unique") unless Companies::CheckRegistrationNumberUniqueness.new(value).call
  end
end
