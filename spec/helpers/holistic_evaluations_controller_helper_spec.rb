require "rails_helper"

describe HolisticEvaluationsControllerHelper, type: :helper do
  include_context "holistic evaluations details"

  describe "#split_holistic_evaluation" do
    it "returns splits evaluations according to unique criteria" do
      expect(evaluation_groups.length).to eql 2
    end
  end

  describe "#get_prepared_scores_history" do
    it "returns scores history with average set correctly" do
      holistic_evaluation = get_prepared_scores_history(evaluation_groups[0])
      expect(holistic_evaluation[:average]).to eq 1.5
    end
  end

  describe "#prepare_scores_history_details" do
    @example_evaluation_details = {
      Quantity: {
        score: 2,
        comment: "Good"
      },
      Quality: {
        score: 1,
        comment: "You can improve"
      }
    }

    context "when average is nil" do
      it "returns details hash with average set to N/A" do
        scores_details = prepare_scores_history_details(
          holistic_evaluations,
          @example_evaluations_details,
          nil
        )

        expect(scores_details[:average]).to eql "N/A"
      end
    end

    context "when average is not nil" do
      it "returns details hash with average rounded correctly" do
        scores_details = prepare_scores_history_details(
          holistic_evaluations,
          @example_evaluations_details,
          2
        )

        expect(scores_details[:average]).to eql 2.0
      end
    end
  end

  describe "#prepare_evaluation_details" do
    it "returns correct details for each attribute" do
      evaluation_details = prepare_evaluation_details(
        evaluations
      )

      first_attribute = evaluation_details.keys[0]
      expect(evaluation_details[first_attribute.to_sym]).to eq [1]
    end
  end

  describe "#calculate_criteria_averages" do
    it "returns correct averages for criteria" do
      criteria_averages = calculate_criteria_averages(
        holistic_evaluation_details
      )

      expect(criteria_averages[:Quality]).to eq 0.0
      expect(criteria_averages[:Integration]).to eq 1.0
    end
  end

  describe "#calculate_submission_average" do
    it "returns correct averages for criteria" do
      submission_average = calculate_submission_average(evaluation_groups[0])

      expect(submission_average).to eq 1.5
    end
  end

  describe "#eligibility_status" do
    context "when a learner has been evaluated once\
             and is therefore eligible for evaluation" do
      it "returns true and one evaluation received" do
        eligibility_status = eligibility_status(learner_program.id)

        expect(eligibility_status[:eligible]).to be true
        expect(eligibility_status[:evaluations_received]).to eq(1)
      end
    end

    context "when learner has been evaluated twice\
             and is therefore not eligible for another evaluation" do
      let!(:new_holistic_evaluations) do
        create_list(
          :holistic_evaluation,
          2,
          learner_program: learner_program,
          evaluation_average: evaluation_average
        )
      end

      it "returns false and two evaluations received" do
        eligibility_status = eligibility_status(learner_program.id)

        expect(eligibility_status[:eligible]).not_to be true
        expect(eligibility_status[:evaluations_received]).to eq(2)
      end
    end

    context "when learner id does not exist in database" do
      it "returns false and zero evaluations received" do
        eligibility_status = eligibility_status(777)

        expect(eligibility_status[:eligible]).not_to be true
        expect(eligibility_status[:evaluations_received]).to eq(0)
      end
    end
  end
end
