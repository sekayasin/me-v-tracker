require "rails_helper"
require "helpers/holistic_evaluation_helpers"

RSpec.describe CsvHeaderService do
  let!(:criteria) { create_list(:criterium, 4) }
  let!(:phases) { create_list(:phase, 4) }

  before(:all) do
    @learner_program = create(:learner_program)
  end

  describe ".second_csv_header" do
    it "populates the second csv header" do
      second_csv_header = CsvHeaderService.second_csv_header(
        @learner_program.program_id, criteria, phases
      )

      expect(second_csv_header.include?("Greenhouse Candidate ID")).to eq true
    end
  end

  describe ".first_csv_header" do
    it "populates the first csv header" do
      first_csv_header = CsvHeaderService.first_csv_header(
        @learner_program.program_id,
        criteria,
        phases
      )

      expect(first_csv_header.include?("Biodata")).to eq true
    end
  end

  describe ".first_holistic_header" do
    it "populates the first csv header" do
      first_csv_header = CsvHeaderService.first_holistic_header(
        @learner_program.bootcamper
      )
      header_text = "Holistic Evaluation Performance for"
      camper = @learner_program.bootcamper

      expect(first_csv_header.include?(
               "#{header_text} #{camper.first_name} #{camper.last_name}"
             )).to eq true
    end
  end

  describe ".first_holistic_header" do
    it "populates the second csv header" do
      second_csv_header = CsvHeaderService.second_holistic_header(
        HolisticEvaluationHelpers.evaluation_details
      )
      expect(second_csv_header.include?("EPIC Score")).to eq true
    end
  end
end
