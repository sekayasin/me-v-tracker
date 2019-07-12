require "rails_helper"

RSpec.describe DashboardController, type: :controller do
  include DashboardConcern

  let(:center) { create(:center, name: "Lagos", country: "Nigeria") }
  let(:center_one) { create(:center, name: "Nairobi", country: "Kenya") }

  let(:cycle_one) { create(:cycle) }
  let(:cycle_two) { create(:cycle) }

  let(:cycle_center_one) do
    create(:cycle_center, :inactive,
           center_id: center.center_id,
           cycle_id: cycle_one.cycle_id,
           program_id: 1)
  end

  let!(:targets) { create(:target) }

  let(:cycle_center_two) do
    create(:cycle_center, center: center, cycle: cycle_two, program_id: 1)
  end

  let(:rating_one) { create(:nps_rating, rating: 1) }
  let(:rating_seven) { create(:nps_rating, rating: 7) }
  let(:rating_ten) { create(:nps_rating, rating: 10) }
  let(:rating_invalid) { create(:nps_rating, rating: 20) }

  let(:nps_question) { create(:nps_question) }
  let!(:nps_responses) do
    create(:nps_response,
           camper_id: create(:bootcamper).id,
           nps_ratings_id: rating_one.nps_ratings_id,
           nps_question_id: nps_question.nps_question_id,
           cycle_center_id: cycle_center_one.cycle_center_id)
    create(:nps_response,
           camper_id: create(:bootcamper).id,
           nps_ratings_id: rating_seven.nps_ratings_id,
           nps_question_id: nps_question.nps_question_id,
           cycle_center_id: cycle_center_one.cycle_center_id)
    create(:nps_response,
           camper_id: create(:bootcamper).id,
           nps_ratings_id: rating_ten.nps_ratings_id,
           nps_question_id: nps_question.nps_question_id,
           cycle_center_id: cycle_center_one.cycle_center_id)
    create(:nps_response,
           camper_id: create(:bootcamper).id,
           nps_ratings_id: rating_invalid.nps_ratings_id,
           nps_question_id: nps_question.nps_question_id,
           cycle_center_id: cycle_center_one.cycle_center_id)
  end

  let!(:learner_programs) do
    create :learner_program, program_id: 1, cycle_center: cycle_center_one
    create :learner_program, program_id: 1, cycle_center: cycle_center_one
    create :learner_program, program_id: 1, cycle_center: cycle_center_two
    create :learner_program, program_id: 1, cycle_center: cycle_center_two,
                             decision_one: "Rejected"
    create :learner_program, program_id: 1, cycle_center: cycle_center_two,
                             decision_one: "Advanced",
                             decision_two: "Accepted"
    create :learner_program, program_id: 1, cycle_center: cycle_center_two,
                             decision_one: "Advanced"
    create :learner_program, program_id: 1, cycle_center: cycle_center_one
    create :learner_program, program_id: 1, cycle_center: cycle_center_one,
                             decision_one: "Advanced",
                             decision_two: "Accepted"
  end
  let(:json) { JSON.parse(response.body) }
  let(:one) { cycle_one.cycle.to_s }
  let(:two) { cycle_two.cycle.to_s }

  describe "GET #cycle_center_metrics" do
    before do
      stub_current_user(:user)
      get :cycle_center_metrics, params: { program_id: 1, center: "Lagos" }
    end

    it "returns a hash containing cycles per center" do
      assert_response :success
      expect(json["cycles"]).to eq [cycle_two.cycle, cycle_one.cycle]
      expect(json["gender_distribution"][one]["total"]).to eq(4)
    end

    it "returns a JSON payload with week 1 program outcome metrics data" do
      assert_response :success
      expect(json["week_one_decisions"].keys).to eq [two, one]
      expect(json["week_one_decisions"][one].keys).
        to eq LearnerProgram.week_one_decisions
      expect(json["week_one_decisions"][two].keys).
        to eq LearnerProgram.week_one_decisions
    end

    it "returns program outcome metrics with decision totals and percentages" do
      assert_response :success
      expect(json["week_one_decisions"][two]["Advanced"].keys).
        to eq %w(total_count percentage)
      expect(json["week_one_decisions"][two]["Advanced"]["total_count"]).
        to eq(2)
      expect(json["week_one_decisions"][two]["Rejected"]["total_count"]).
        to eq(1)
      expect(json["week_one_decisions"][two]["Advanced"]["percentage"]).
        to eq("66.7")
    end

    it "excludes the non-required decision, in_progress" do
      expect(json["week_one_decisions"][one].keys).not_to include "in_progress"
    end

    it "returns program metrics for week 2" do
      assert_response :success
      expect(json["week_two_cycle_metrics"]).to(include cycle_one.cycle.to_s)
      expect(
        json["week_two_cycle_metrics"][cycle_one.cycle.to_s]
      ).to include "totals"
      expect(
        json["week_two_cycle_metrics"][cycle_one.cycle.to_s]
      ).to include "percentage"
    end
  end

  describe "GET #program_metrics" do
    let(:program_health_metrics_week_one_attrs) do
      json["phase_one_metrics"]["decisions"]
    end

    let(:phase_one_attrs) { json["phase_one_totals"].keys }
    before do
      stub_current_user(:user)
      get :program_metrics, params: { program_id: 1, phase: "phase_one" }
    end

    it "returns all the required program metrics" do
      assert_response :success
      expect(json.keys).to include "min_max_dates"
      expect(json.keys).to include "cycles_per_centre"
      expect(json.keys).to include "phase_two_metrics"
      expect(json.keys).to include "phase_one_metrics"
      expect(json.keys).to include "learners_dispersion_data"
      expect(json.keys).to include "lfa_to_learner_ratio"
      expect(json.keys).to include "gender_distribution_data"
      expect(json.keys).to include "perceived_readiness_genders"
      expect(json.keys).to include "perceived_readiness_percentages"
    end

    it "returns a JSON payload with week 1 program metrics data" do
      assert_response :success
      expect(
        json["phase_one_metrics"]["decisions"]
      ).to eq ["In Progress", "Advanced", "Rejected"]
    end

    it "returns the required decisions" do
      expect(program_health_metrics_week_one_attrs).to include "Advanced"
      expect(program_health_metrics_week_one_attrs).to include "Rejected"
    end

    it "excludes the non-required decision, in_progress" do
      expect(program_health_metrics_week_one_attrs).not_to include "in_progress"
    end

    it "returns both phase_metric attribute" do
      expect(json.keys).to include "phase_one_metrics"
      expect(json.keys).to include "phase_two_metrics"
    end

    context "#phase_two_metrics" do
      it "returns a json object with 3 decisions" do
        expect(json["phase_two_metrics"].size).to eq 3
      end

      it "has Accepted Criteria" do
        expect(json["phase_two_metrics"]["decisions"]).to include("Accepted")
        expect(json["phase_one_metrics"]["decisions"]).to include("Advanced")
      end

      it "doesn't contain In Progress decisions" do
        expect(json["phase_two_metrics"]).to_not include("In Progress")
        expect(json["phase_one_metrics"]).to_not include("Accepted")
      end
    end

    context "#phase_one_metrics" do
      it "returns a data containing cycles" do
        cycles_per_centre = json["cycles_per_centre"]
        expect(cycles_per_centre["Lagos"]).to eq 2
      end

      it "returns program one metrics" do
        assert_response :success
        expect(json["phase_one_metrics"].keys).to include "decisions"
        expect(json["phase_one_metrics"].keys).to include "totals"
        expect(json["phase_one_metrics"].keys).to include "percentages"
      end
    end
  end

  describe "GET # program_feedback_centers" do
    before do
      stub_current_user(:user)
      get :program_feedback_centers, params: { program_id: 1 }
    end

    it "returns inactive centers with feedback" do
      assert_response :success
      expect(json[center.name]).to eq [cycle_one.cycle]
    end
  end

  describe "GET # program_feedback" do
    before do
      stub_current_user(:user)
      get :program_feedback,
          params: { program_id: 1, center: center.name, cycle: cycle_one.cycle }
    end

    it "returns centers with feedback" do
      assert_response :success
      expect(json[0]["title"]).to eq nps_question.title
      expect(json[0]["description"]).to eq nps_question.description
      expect(json[0]["nps_totals"]).to eq [1, 1, 1]
    end
  end

  describe "includes DashboardConcern" do
    it "includes the dashboard concern" do
      expect(
        DashboardControllerHelper.ancestors.include?(DashboardConcern)
      ).to eq true
    end
  end
end
