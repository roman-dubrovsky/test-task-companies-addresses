# frozen_string_literal: true

RSpec.describe Company do
  describe "validations and associations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(256) }
    it { is_expected.to validate_presence_of(:registration_number) }
    it { is_expected.to validate_uniqueness_of(:registration_number) }

    it { is_expected.to have_many(:addresses).dependent(:destroy) }
  end
end
