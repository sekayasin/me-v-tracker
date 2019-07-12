require "rails_helper"

RSpec.describe LanguageStack, type: :model do
  describe "Validations" do
    it { is_expected.to have_many(:programs).through(:dlc_stacks) }
    it { is_expected.to have_many(:bootcampers) }
  end

  describe "when validating fields" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
