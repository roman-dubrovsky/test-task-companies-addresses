# frozen_string_literal: true

module Companies
  class ImportFromCsv < Dry::Operation
    def call(file)
      store = step read_file(file)
      contracts = step validate(store)
      ids = step create(contracts)
      Company.where(id: ids).includes(:addresses)
    end

    private

    def read_file(file)
      Companies::ImportFromCsv::ReadCsv.new(file).call
    end

    def validate(store)
      contracts = store.values.map do |data|
        CompanyContract.new.call(data)
      end

      valid = contracts.all?(&:success?)

      valid ? Success(contracts) : Failure(:unexpected_validation_error)
    end

    def create(contracts)
      companies = contracts.map do |contract|
        Company.new(
          name: contract[:name],
          registration_number: contract[:registration_number],
          addresses_attributes: contract[:addresses],
        )
      end

      result = Company.import companies, validate: false, recursive: true

      Success(result.ids)
    end
  end
end
