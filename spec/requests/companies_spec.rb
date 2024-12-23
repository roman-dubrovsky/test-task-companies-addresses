# frozen_string_literal: true

RSpec.describe "Companies API", type: :request do
  let(:json_response) { response.parsed_body }

  describe "POST /companies" do
    subject(:do_request) { post "/companies", params: {company: params} }

    let(:company) { build(:company) }
    let(:address) { build(:address) }

    let(:params) { single_request_params(company, [address]) }

    context "when valid example with single address" do
      it "returns created status code" do
        do_request

        expect(response).to have_http_status(:created)
      end
    end

    context "when valid example with multiple addresses"

    context "when validation error" do
      before do
        create(:company, registration_number: company.registration_number)
      end

      it "returns bad request status code with errors" do
        do_request

        expect(response).to have_http_status(:bad_request)
        expect(json_response).to eq({"registration_number" => ["must be unique"]})
      end
    end
  end
end
