require "rails_helper"

RSpec.describe Impression, type: :model do
  describe "Associations" do
    it { is_expected.to have_many(:feedback) }
  end

  describe "Validations" do
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
