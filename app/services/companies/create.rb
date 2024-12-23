# frozen_string_literal: true

module Companies
  class Create < Dry::Operation
    def call(params)
      contract = step validate(params)
      step create(contract)
    end

    private

    def validate(params)
      contract = CompanyContract.new.call(params.to_h)

      contract.success? ? Success(contract) : Failure(contract.errors.to_h)
    end

    def create(contract)
      company = Company.create!(
        name: contract[:name],
        registration_number: contract[:registration_number],
        addresses_attributes: contract[:addresses],
      )

      Success(company)
    end

    # If we care about N + 1 queries on adding addresses
    # Just use batch inserting
    # def create(contract)
    #   company = Company.create!(
    #     name: contract[:name],
    #     registration_number: contract[:registration_number],
    #   )

    #   Address.insert_all!(
    #     contract[:addresses].map do |address|
    #       address.merge(company_id: company.id)
    #     end,
    #   )

    #   Success(company)
    # end
  end
end
