require "rails_helper"

RSpec.describe ProgramsHelper, type: :helper do
  let(:program) { create :program }
  let(:framework) { create :framework }
  let(:criterium) { create :criterium }
  let(:framework_detail) do
    [{
      total_track: 4,
      framework_name: "Feedback",
      framework_id: 3
    },
     {
       total_track: 5,
       framework_name: "Output",
       framework_id: 1
     }]
  end

  describe ".calculate_tracked_assessment" do
    it "calculates tracked outputs in percentage" do
      tracked_framework = calculate_tracked_assessment(
        framework_detail[0][:total_track],
        framework_detail
      )
      expect(tracked_framework).to eql(44)
    end
  end

  describe ".calculate_total_assessment" do
    it "calculates total tracked assessments" do
      total = calculate_total_assessment(
        framework_detail
      )
      expect(total).to eql(9)
    end
  end

  describe ".get_program_description" do
    it "Get description of a program" do
      description = get_program_description(program)
      expect(description).to eql(program.description)
    end
  end

  describe ".get_criterium_assessments" do
    it "Get get criterium assessments" do
      create(:framework_criterium, framework: framework, criterium: criterium)
      assessments = get_criterium_assessments(framework)
      expect(assessments.count).to eql(0)
    end
  end
end
