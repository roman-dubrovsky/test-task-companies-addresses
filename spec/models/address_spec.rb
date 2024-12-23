# frozen_string_literal: true

RSpec.describe Address do
  describe "validations and associations" do
    it { is_expected.to validate_presence_of(:street) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:country) }

    it { is_expected.to belong_to(:company) }
  end
end
