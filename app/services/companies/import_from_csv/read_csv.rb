# frozen_string_literal: true

module Companies
  class ImportFromCsv
    class ReadCsv < Dry::Operation
      def initialize(file)
        super()

        @store = {}
        @errors = {}
        @file = file
      end

      def call
        step read_file
      end

      private

      attr_reader :file, :store, :errors

      def read_file
        CSV.foreach(file.path, headers: true).with_index(1) do |row, line_index|
          data = row.to_h
          registration_number = data["registration_number"]

          add_to_store(data, registration_number)
          validate_line(data, line_index)
          validate_name(data, registration_number, line_index)
        end

        errors.any? ? Failure(errors) : Success(store)
      end

      def add_to_store(data, registration_number)
        store[registration_number] ||= company_info(data)
        store[registration_number]["addresses"] ||= []
        store[registration_number]["addresses"] << address_info(data)
      end

      def validate_line(data, line_index)
        line_contract = CompanyContract.new.call(
          company_info(data).merge("addresses" => [address_info(data)]),
        )
        errors[line_index] = format_error(line_contract) unless line_contract.success?
      end

      def validate_name(data, registration_number, line_index)
        return unless store[registration_number]["name"] != data["name"] && data["name"].present?

        errors[line_index] ||= {}
        errors[line_index][:registration_number] ||= []
        errors[line_index][:registration_number] << "already present in the file"
      end

      def format_error(contract)
        errors = contract.errors.to_h.dup

        if errors[:addresses].present?
          errors = errors.merge(errors[:addresses][0])
          errors.delete(:addresses)
        end

        errors
      end

      def company_info(data)
        data.slice("name", "registration_number")
      end

      def address_info(data)
        data.slice("street", "city", "postal_code", "country")
      end
    end
  end
end
