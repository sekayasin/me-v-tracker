require "rails_helper"

RSpec.describe Facilitator, type: :model do
  describe "Facilitator Associations" do
    it { is_expected.to have_many(:week_one_facilitators) }
    it { is_expected.to have_many(:week_two_facilitators) }
  end

  describe "Facilitators Table" do
    subject { create(:facilitator) }
    it { is_expected.to validate_uniqueness_of(:id) }
    it { is_expected.to validate_presence_of(:email) }

    it "generates a facilitator Id" do
      expect(Facilitator.generate_facilitator_id).to be_a String
    end

    it "creates a unique facilitator Id" do
      first_facilitator_id = Facilitator.generate_facilitator_id
      second_facilitator_id = Facilitator.generate_facilitator_id
      expect(first_facilitator_id).not_to eql second_facilitator_id
    end
  end
end
