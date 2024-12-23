# frozen_string_literal: true

RSpec.describe Companies::Create do
  subject(:create_company) do
    described_class.new.call(params)
  end

  let(:created_company) { create_company.success }

  let(:company) { build(:company) }
  let(:primary_address) { build(:address) }
  let(:secondary_address) { build(:address) }

  let(:addresses) { [primary_address, secondary_address] }

  let(:params) { single_request_params(company, addresses) }

  context "when valid params are passed" do
    it "creates a new company" do
      expect { create_company }.to change { Company.count }.by(1)
    end

    it "returns created company" do
      expect(created_company).to eq Company.last
    end

    it "sets correct name" do
      expect(created_company.name).to eq company.name
    end

    it "sets correct registration number" do
      expect(created_company.registration_number).to eq company.registration_number
    end

    it "creates new addresses" do
      expect { create_company }.to change { Address.count }.by(2)
    end

    it "associate two created addresses" do
      expect(created_company.addresses.count).to be 2
    end

    %w[city country postal_code street].each do |field|
      it "sets correct #{field}" do
        actual = addresses.map { |a| a.public_send(field) }
        created = created_company.addresses.map { |a| a.public_send(field) }

        expect(created).to match_array(actual)
      end
    end
  end

  context "when company is not valid" do
    let(:primary_address) { build(:address, city: "") }

    it "does not eturn success result" do
      expect(create_company.success).to be_nil
    end

    it "returns errors hash" do
      expect(create_company.failure).to eq({addresses: {0 => {city: ["is missing"]}}})
    end

    it "does not create a new company" do
      expect { create_company }.not_to change { Company.count }
    end

    it "does not create new addresses" do
      expect { create_company }.not_to change { Address.count }
    end
  end
end
