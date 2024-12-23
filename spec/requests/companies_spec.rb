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
end
