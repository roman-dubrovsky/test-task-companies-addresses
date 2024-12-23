# frozen_string_literal: true

RSpec.describe CompanyContract do
  subject { described_class.new.call(params) }

  let(:company) { build(:company) }
  let(:address) { build(:address) }
  let(:valid_address) { build(:address) }

  let(:original_params) { single_request_params(company, [address, valid_address]) }
  let(:params) { original_params }

  context "when valid example" do
    its(:success?) { is_expected.to be true }
  end

  context "when name is missing" do
    let(:company) { build(:company, name: nil) }

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        name: ["is missing"],
      })
    end
  end

  context "when name is empty" do
    let(:company) { build(:company, name: "") }

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        name: ["must be filled"],
      })
    end
  end

  context "when name is too lond" do
    let(:company) { build(:company, name: "a" * 257) }

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        name: ["must be at most 256 characters"],
      })
    end
  end

  context "when registration number is missing" do
    let(:company) { build(:company, registration_number: nil) }

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        registration_number: ["is missing"],
      })
    end
  end

  context "when registration number is not number" do
    let(:params) { original_params.merge("registration_number" => "test") }

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        registration_number: ["must be an integer"],
      })
    end
  end

  context "when registration number is not unique" do
    before do
      create(:company, registration_number: company.registration_number)
    end

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        registration_number: ["must be unique"],
      })
    end
  end

  context "when address street is missing" do
    let(:address) { build(:address, street: nil) }

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        addresses: {
          0 => {
            street: ["is missing"],
          },
        },
      })
    end
  end

  context "when address city is missing" do
    let(:address) { build(:address, city: nil) }

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        addresses: {
          0 => {
            city: ["is missing"],
          },
        },
      })
    end
  end

  context "when address country is missing" do
    let(:address) { build(:address, country: nil) }

    its(:success?) { is_expected.to be false }

    its("errors.to_h") do
      is_expected.to eq({
        addresses: {
          0 => {
            country: ["is missing"],
          },
        },
      })
    end
  end

  context "when address postal code is missing" do
    let(:address) { build(:address, postal_code: nil) }

    its(:success?) { is_expected.to be true }
  end
end
