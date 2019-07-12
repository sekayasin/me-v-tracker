require "rails_helper"

RSpec.describe BootcampersLanguageStack, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to(:bootcamper).with_foreign_key(:camper_id) }
    it { is_expected.to belong_to(:language_stack) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:camper_id) }
    it { is_expected.to validate_presence_of(:language_stack_id) }
  end
end
