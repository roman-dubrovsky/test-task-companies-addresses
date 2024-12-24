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

  def generate_csv_data(dataset)
    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      dataset.each do |data|
        csv << data
      end
    end
  end

  def companies_and_addresses_csv_data(companies)
    companies.map do |company|
      company.addresses.map do |address|
        csv_line(company, address)
      end
    end.flatten(1).shuffle
  end

  def csv_line(company, address)
    [
      company.name,
      company.registration_number,
      address.street,
      address.city,
      address.postal_code,
      address.country,
    ]
  end

  def csv_headers
    %w[name registration_number street city postal_code country]
  end
end
