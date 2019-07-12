require "rails_helper"
require "helpers/holistic_evaluation_helpers"

RSpec.describe BootcampersCsvService do
  let(:learner_program) { create :learner_program }
  let(:params) do
    {
      cycle: "All",
      city: "All",
      week_one_lfa: "All",
      week_two_lfa: "All",
      decision_one: "All",
      decision_two: "All",
      program_id: learner_program.program_id
    }
  end

  describe ".generate_report" do
    it "generates a csv report" do
      report = []
      BootcampersCsvService.generate_report(params) { |d| report << d.to_s }
      expect(
        report[2].include?(learner_program.week_one_facilitator.email)
      ).to eq true
    end
  end
  describe ".generate_csv_data" do
    it "generates generate csv data" do
      report = BootcampersCsvService.generate_csv_data
      expect(report).to eq nil
    end
  end

  describe ".build_query" do
    before(:each) do
      BootcampersCsvService.instance_variable_set :@program_id, nil
    end
    it "generates generate csv data" do
      report = BootcampersCsvService.build_query
      expected = {}
      expect(report).to eq expected
    end
  end

  describe ".sanitize_decision_param" do
    it "return all if decision is all" do
      decision = "All"
      decision = BootcampersCsvService.sanitize_decision_param(decision)
      expect(decision).to eq nil
    end
    it "return array if decisions" do
      decision = "All,Levelup,Advanced"
      decision = BootcampersCsvService.sanitize_decision_param(decision)
      expect(decision).to eq %w(All Levelup Advanced)
    end
  end

  describe ".generate_holistic_evaluation_report" do
    it "generates holistic evaluation csv report" do
      report = BootcampersCsvService.generate_holistic_evaluation_report(
        HolisticEvaluationHelpers.evaluation_details,
        learner_program.bootcamper
      )
      expect(report.include?(learner_program.bootcamper.first_name)).to eq true
    end
  end
end
