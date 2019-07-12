require "rails_helper"

RSpec.describe Reflection, type: :model do
  describe "Reflection associations" do
    it { is_expected.to belong_to(:feedback) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:comment) }
  end
end
