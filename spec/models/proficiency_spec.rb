require "rails_helper"

RSpec.describe Proficiency, type: :model do
  describe "Validations" do
    it { is_expected.to have_many(:bootcampers) }
  end

  describe "when validating fields" do
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:description) }
  end
end
