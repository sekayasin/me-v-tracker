require "rails_helper"

RSpec.describe Point, type: :model do
  context "when validating associations" do
    it { is_expected.to have_many(:metrics) }
  end

  context "when validating fields" do
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:context) }
    it { is_expected.to validate_uniqueness_of(:context) }
  end
end
