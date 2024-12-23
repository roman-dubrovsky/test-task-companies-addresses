# frozen_string_literal: true

RSpec.describe "Companies API", type: :request do
  let(:json_response) { response.parsed_body }

  describe "POST /companies" do
    subject(:do_request) { post "/companies", params: {company: params} }

    let(:company) { build(:company) }
    let(:address) { build(:address) }

    let(:created_company) { Company.last }

    let(:params) { single_request_params(company, [address]) }

    context "when valid example with single address" do
      it "returns created status code" do
        do_request

        expect(response).to have_http_status(:created)
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
