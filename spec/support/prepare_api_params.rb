# frozen_string_literal: true

# Prepare data which will passed in the tests
module PrepareApiParams
  def single_request_params(company, addresses)
    {
      "name" => company.name,
      "registration_number" => company.registration_number,
      "addresses" => addresses.map do |address|
        address.slice("street", "city", "postal_code", "country")
          .compact_blank
      end,
    }.filter { |_value, key| !key.nil? }
  end
end
