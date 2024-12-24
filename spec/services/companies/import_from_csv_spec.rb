# frozen_string_literal: true

RSpec.shared_examples "Companies::ImportFromCsv validation errors" do
  it "does not return success result" do
    expect(import.success).to be_nil
  end

  it "does not create new companies" do
    expect { import }.not_to change { Company.count }
  end

  it "does not create new addresses" do
    expect { import }.not_to change { Address.count }
  end
end

RSpec.describe Companies::ImportFromCsv do
  subject(:import) { described_class.new.call(file) }

  let(:csv) { generate_csv_data(csv_data) }
  let(:csv_data) { original_csv_data }
  let(:original_csv_data) { companies_and_addresses_csv_data(companies) }
  let(:companies) { [large_company, small_company, single_address_company] }

  let(:large_company) { build(:company_with_addresses, addresses_count: 5) }
  let(:small_company) { build(:company_with_addresses) }
  let(:single_address_company) { build(:company_with_addresses, addresses_count: 1) }

  let(:lines_with_indxes) do
    csv_data.map.with_index.map do |data, index|
      [data[1], index]
    end
  end

  let(:file) do
    file = instance_double(ActionDispatch::Http::UploadedFile, path:)

    allow(File).to receive(:open)
      .with(path, "r", anything)
      .and_return(StringIO.new(csv))

    file
  end

  let(:path) { "file_path.csv" }

  before do
    allow(File).to receive(:open).and_call_original
  end

  context "when valid example" do
    it "returns success status" do
      expect(import.success).to match_array(Company.where(registration_number: companies.map(&:registration_number)))
    end

    it "creates new companies" do
      expect { import }.to change { Company.count }.by(3)
    end

    it "creates new addresses" do
      expect { import }.to change { Address.count }.by(8)
    end

    context "when 1 company with 1 address" do
      let(:company) { single_address_company }
      let(:address) { company.addresses.first }

      let(:companies) { [company] }

      let(:created_company) { Company.last }
      let(:created_address) { Address.last }

      it "sets correct name" do
        import
        expect(created_company.name).to eq company.name
      end

      it "sets correct company registration number" do
        import
        expect(created_company.registration_number).to eq company.registration_number
      end

      it "assign created address to company" do
        import
        expect(created_company.addresses).to contain_exactly(created_address)
      end

      it "sets correct address postal code" do
        import
        expect(created_address.postal_code).to eq address.postal_code
      end

      it "sets correct address city" do
        import
        expect(created_address.city).to eq address.city
      end

      it "sets correct address country" do
        import
        expect(created_address.country).to eq address.country
      end

      it "sets correct address street" do
        import
        expect(created_address.street).to eq address.street
      end
    end
  end

  context "when address validation error" do
    let(:error_line) do
      csv_data.find_index { |data| data[1] == single_address_company.registration_number }
    end

    before do
      single_address_company.addresses.first.city = ""
    end

    include_examples "Companies::ImportFromCsv validation errors"

    it "returns formatted error" do
      expect(import.failure).to eq({
        (error_line + 1) => {
          city: ["must be filled"],
        },
      })
    end
  end

  context "when one of company name is missed" do
    let(:large_company_indexes) do
      lines_with_indxes.filter { |data| data.first == large_company.registration_number }
        .map(&:last)
    end

    let(:error_line) do
      large_company_indexes[1..4].sample
    end

    before do
      csv_data[error_line][0] = ""
    end

    include_examples "Companies::ImportFromCsv validation errors"

    it "returns formatted error" do
      expect(import.failure).to eq({
        (error_line + 1) => {
          name: ["must be filled"],
        },
      })
    end
  end

  context "when no unique names for one registration number in the file" do
    let(:large_company_indexes) do
      lines_with_indxes.filter { |data| data.first == large_company.registration_number }
        .map(&:last)
    end

    let(:error_line) do
      large_company_indexes[1..4].sample
    end

    before do
      csv_data[error_line][0] = "random name"
    end

    include_examples "Companies::ImportFromCsv validation errors"

    it "returns formatted error" do
      expect(import.failure).to eq({
        (error_line + 1) => {
          registration_number: ["already present in the file"],
        },
      })
    end
  end

  context "when company has been already created in the database" do
    let(:error_line) do
      lines_with_indxes.filter { |data| data.first == single_address_company.registration_number }
        .first.last
    end

    before do
      create(:company, registration_number: single_address_company.registration_number)
    end

    include_examples "Companies::ImportFromCsv validation errors"

    it "returns formatted error" do
      expect(import.failure).to eq({
        (error_line + 1) => {
          registration_number: ["must be unique"],
        },
      })
    end
  end
end
