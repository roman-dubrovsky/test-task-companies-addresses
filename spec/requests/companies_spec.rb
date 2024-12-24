# frozen_string_literal: true

RSpec.describe "Companies API", type: :request do
  let(:json_response) { response.parsed_body }

  describe "POST /companies" do
    subject(:do_request) { post "/companies", params: {company: params} }

    let(:company) { build(:company) }
    let(:address) { build(:address) }

    let(:created_company) { Company.last }

    let(:params) { single_request_params(company, [address]) }

    let(:expected_response) do
      {
        "id" => created_company.id,
        "name" => company.name,
        "registration_number" => company.registration_number,
        "addresses" => [
          {
            "id" => created_company.addresses.first.id,
            "street" => address.street,
            "city" => address.city,
            "postal_code" => address.postal_code,
            "country" => address.country,
          },
        ],
      }
    end

    context "when valid example with single address" do
      it "returns created status code with response" do
        do_request

        expect(response).to have_http_status(:created)
        expect(json_response).to eq(expected_response)
      end

      it "creates new company with address" do
        expect { do_request }.to change { Company.count }.by(1)

        expect(created_company.addresses.count).to be 1
        expect(created_company.name).to eq company.name
        expect(created_company.addresses.first.street).to eq address.street
      end
    end

    context "when validation error" do
      before do
        create(:company, registration_number: company.registration_number)
      end

      it "returns bad request status code with errors" do
        do_request

        expect(response).to have_http_status(:bad_request)
        expect(json_response).to eq({"registration_number" => ["must be unique"]})
      end

      it "does not create new companies" do
        expect { do_request }.not_to change { Company.count }
      end
    end
  end

  describe "POST /companies/import" do
    subject(:do_request) { post "/companies/import", params: {file: csv_file} }

    let(:csv_file) { StringIO.new(csv) }
    let(:json_response) { response.parsed_body }

    let(:csv) { generate_csv_data(csv_data) }
    let(:csv_data) { companies_and_addresses_csv_data(companies) }
    let(:companies) { [large_company, small_company, single_address_company] }

    let(:large_company) { build(:company_with_addresses, addresses_count: 5) }
    let(:small_company) { build(:company_with_addresses) }
    let(:single_address_company) { build(:company_with_addresses, addresses_count: 1) }

    context "when valid example" do
      let(:small_company_response) do
        json_response.find { |resp| resp["registration_number"] == small_company.registration_number }
      end

      let(:created_small_company) { Company.find_by(registration_number: small_company.registration_number) }

      let(:expected_response) do
        {
          id: created_small_company.id,
          name: small_company.name,
          registration_number: small_company.registration_number,
          addresses: [],
        }
      end

      let(:created_companies) { Company.last(3) }

      it "returns 201 status code with correct data" do
        do_request

        expect(response).to have_http_status(:created)
        expect(json_response.count).to be 3
        expect(small_company_response).to eq expected_response
      end

      it "creates new companies" do
        expect { do_request }.to change { Company.count }.by(3)
        expect(created_companies.pluck(:registration_number)).to match_array(companies.map(&:registration_number))
      end

      it "creates new addresses" do
        expect { do_request }.to change { Address.count }.by(8)
      end
    end

    context "when validation errors" do
      let(:single_address_line) { csv_data.index { |d| d[1] == single_address_company.registration_number } }
      let(:wrong_company_line) do
        csv_data.map.with_index { |data, index| [data, index] }
          .filter { |data, _index| data[1] == small_company.registration_number }
          .map(&:last).max
      end

      before do
        single_address_company.addresses.first.city = ""
        csv_data[wrong_company_line][0] = "Invalid Company Name"
      end

      it "returns bad request with errors list" do
        do_request

        expect(response).to have_http_status(:bad_request)
      end

      it "does not create new companies" do
        expect { do_request }.not_to change { Company.count }
      end

      it "does not create new addresses" do
        expect { do_request }.not_to change { Address.count }
      end
    end
  end
end
