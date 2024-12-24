# frozen_string_literal: true

class CompanyContract < ApplicationContract
  attr_reader :registration_number_validator

  def initialize(registration_number_validator: nil)
    super()
    @registration_number_validator = registration_number_validator || Companies::CheckRegistrationNumberUniqueness.new
  end

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
    key.failure("must be unique") unless registration_number_validator.call(value)
  end
end
