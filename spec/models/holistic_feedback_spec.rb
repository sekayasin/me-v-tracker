require "rails_helper"

RSpec.describe HolisticFeedback, type: :model do
  include_context "holistic feedback details"

  describe "Associations" do
    it { is_expected.to belong_to(:learner_program) }
    it { is_expected.to belong_to(:criterium) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:learner_program_id) }
    it { is_expected.to validate_presence_of(:criterium_id) }
    it { is_expected.to validate_presence_of(:comment) }
  end

  describe ".create" do
    let(:learner_program) { create :learner_program }
    let(:criterium) { create :criterium }
    it "populates the HolisticFeedback table with the data" do
      feedback_details = {
        comment: "comment", learner_program_id: learner_program.id,
        criterium_id: criterium.id
      }
      feedback_instance = HolisticFeedback.create!(feedback_details)
      expect(feedback_instance.comment).to eql feedback_details[:comment]
    end
  end
end
