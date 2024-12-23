# frozen_string_literal: true

module Companies
  class CheckRegistrationNumberUniqueness
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def call
      Company.where(registration_number: value).none?
    end
  end
end
