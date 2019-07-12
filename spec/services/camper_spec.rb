require "rails_helper"
require "helpers/holistic_evaluation_helpers"

RSpec.describe CamperDataService do
  decisions = { decision_one: "In Progress", decision_two: "Not Applicable",
                week_two_lfa: "Unassigned" }
  before(:all) do
    @learner_program = create(:learner_program)
    @decision_one = create(
      :decision,
      decision_stage: 1,
      learner_programs_id: @learner_program.id
    )
    @decision_two = create(
      :decision,
      decision_stage: 2,
      learner_programs_id: @learner_program.id
    )
    @camper_data = CamperDataService.get_camper_data(1, @learner_program)
    assessment = Assessment.find_or_create_by(name: Assessment.first.name)
    phase = Phase.find_or_create_by(name: Phase.first.name)
    @phases = Phase.select(:id).includes(:assessments)
    create(
      :score,
      learner_programs_id: @learner_program.id,
      score: 3,
      assessment: assessment,
      phase_id: phase.id
    )

    @camper_score = CamperDataService.get_camper_score(
      @learner_program.scores, @phases
    )

    @csv_data = CamperDataService.holistic_csv_data(
      HolisticEvaluationHelpers.evaluation_details[0]
    )
  end

  let(:program) { Program.first }
  let!(:learner_program) { create :learner_program, program: program }
  let!(:holistic_evaluation) do
    create :holistic_evaluation, learner_program: learner_program
  end

  describe ".decide" do
    context "for nil decision_one, decision_two, week_two_lfa" do
      it "it returns 'In Progress', 'Unassigned', 'Not Applicable'" do
        camper = @learner_program
        camper.decision_one = nil
        camper.decision_two = nil
        camper.week_two_facilitator = nil
        decision_one, decision_two, week_two_lfa =
          CamperDataService.decide(camper)
        expect(decision_one).to eql(decisions[:decision_one])
        expect(decision_two).to eql(decisions[:decision_two])
        expect(week_two_lfa).to eql(decisions[:week_two_lfa])
      end
    end
  end

  describe ".get_camper_data" do
    context "when downloading learners csv" do
      it "creates a row with the correct number of columns" do
        expect(@camper_data.size).to eq 23
      end

      it "creates a column with the program of the bootcamper" do
        program = CamperDataService.get_program(@learner_program.program_id)
        expect(@camper_data[7]).to eq program
      end

      it "creates a column with program start date" do
        expect(@camper_data[8]).to eq @learner_program.cycle_center.start_date
      end

      it "creates a column with learner's language stack" do
        expect(@camper_data[9]).to eq @learner_program.
          dlc_stack.language_stack.name
      end

      it "creates a column with the camper's week one decision" do
        expect(@camper_data[13]).to eql(decisions[:decision_one])
      end

      it "creates a column with a reason for the camper's week one decision" do
        decision_one_reasons = CamperDataService.
                               format_decision_reasons(@learner_program, 1)
        expect(@camper_data[14]).to eq decision_one_reasons
      end

      it "creates a column with comments on the camper's week one decision" do
        expect(@camper_data[15]).to eq @decision_one.comment
      end

      it "creates a column with the camper's week two decision" do
        expect(@camper_data[16]).to eql(decisions[:decision_two])
      end

      it "creates a column with a reason for the camper's week two decision" do
        decision_two_reasons = CamperDataService.
                               format_decision_reasons(@learner_program, 2)
        expect(@camper_data[17]).to eq decision_two_reasons
      end

      it "creates a column with comments on the camper's week two decision" do
        expect(@camper_data[18]).to eq @decision_two.comment
      end

      it "creates a column with the overall average" do
        expect(@camper_data[19]).to eq @learner_program.overall_average
      end

      it "creates a column with the values average" do
        expect(@camper_data[20]).to eq @learner_program.value_average
      end

      it "creates a column with output average" do
        expect(@camper_data[21]).to eq @learner_program.output_average
      end

      it "creates a column with feedback one average" do
        expect(@camper_data[22]).to eq @learner_program.feedback_average
      end
    end
  end

  describe ".get_camper_score" do
    context "when downloading learners csv" do
      it "returns the bootcamper's assessments scores" do
        expect(@camper_score.size).to eq 58
      end

      it "returns the score for scored assessment" do
        expect(@camper_score.include?(3.0)).to eq true
      end

      it "returns the score for scored assessment" do
        expect(@camper_score.last).to eq "-"
      end
    end
  end

  describe ".get_holistic_scores" do
    context "when holistic evaluation is provided" do
      it "returns scores" do
        create(:holistic_evaluation, learner_program: learner_program)

        scores = CamperDataService.get_holistic_scores(
          learner_program.id,
          Criterium.get_all_criteria
        )

        expect(scores.values.include?([1])).to eq true
      end
    end

    context "when no holistic evaluation is provided" do
      it "returns an empty array in place" do
        scores = CamperDataService.get_holistic_scores(
          learner_program.id,
          Criterium.get_all_criteria
        )

        expect(scores.values.first).to eq []
        expect(scores.values.first.size).to eq 0
      end
    end
  end

  describe ".get_camper_holistic_data" do
    before do
      @evaluation_count = HolisticEvaluation.
                          program_max_evaluations(program.id)
      @criteria = Criterium.get_program_criteria(program.id)
    end
    it "returns a populated array" do
      holistic_data = CamperDataService.get_camper_holistic_data(
        learner_program.id, program.id, @evaluation_count, @criteria
      )

      expect(holistic_data.include?("-")).to eq true
      expect(holistic_data.count).to be > 1
    end

    it "returns array with correct length" do
      holistic_data = CamperDataService.get_camper_holistic_data(
        learner_program.id, program.id, @evaluation_count, @criteria
      )

      expect(holistic_data.length).
        to eq Criterium.get_program_criteria(program.id).length
    end
  end

  describe ".holistic_csv_data" do
    it "returns a populated array" do
      expect(@csv_data.is_a?(Array)).to be true
    end

    it "returns an array containing evaluation details" do
      evaluation_details = HolisticEvaluationHelpers.evaluation_details[0]

      expect(@csv_data.include?(
               evaluation_details[:created_at][:date]
             )).to be true
      expect(@csv_data.include?(
               evaluation_details[:details][:EPIC][:comment]
             )).to be true
      expect(@csv_data.include?(
               evaluation_details[:details][:EPIC][:score]
             )).to be true
    end
  end
end
