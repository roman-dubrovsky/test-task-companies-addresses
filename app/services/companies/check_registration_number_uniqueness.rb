# frozen_string_literal: true

module Companies
  class CheckRegistrationNumberUniqueness
    attr_reader :memo

    def initialize
      @memo = {}
    end

    def call(value)
      return memo[value] if memo.include? value

      memo[value] = validate(value)
    end

    private

    def validate(value)
      Company.where(registration_number: value).none?
    end
  end
end
