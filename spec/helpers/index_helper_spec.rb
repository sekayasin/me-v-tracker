require "rails_helper"
require_relative "../support/shared_context/score_details"

RSpec.describe IndexHelper, type: :helper do
  include_context "score details"
  include_context "index helper context"

  describe ".pagination_metadata" do
    context "when no result is found" do
      it "has a start count of zero" do
        pagination = pagination_metadata(1, 15, 0, 0)
        expect(pagination).to eq "Showing 0 to 0 of 0 entries"
      end
    end
    context "when result is found" do
      it "has a start count greater than zero" do
        pagination = pagination_metadata(1, 15, 15, 36)
        expect(pagination).to eq "Showing 1 to 15 of 36 entries"
      end
    end
  end

  describe ".page_rows" do
    context "when page is loaded" do
      it "populates dropdown with options 15,30,45,60" do
        expect(page_rows).to eq %w(15 30 45 60)
      end
    end
  end

  describe ".get_total_assessed" do
    it "displays learner's total assessed assessment" do
      phase1_assessments.each do |assessment|
        Score.save_score(
          {
            score: 2.0,
            phase_id: phases[0].id,
            assessment_id: assessment[:id],
            comments: "Good work"
          },
          learner_program.id
        )
      end

      total_assessed = get_total_assessed(learner_program.id)
      expect(total_assessed).to eql(4)
    end
  end

  describe ".get_total_assessments" do
    it "displays total assessments" do
      assessments_per_phase = learner_program.program.phases.map do |phase|
        phase.assessments.length
      end

      total_assessments = get_total_assessments(learner_program.program.id)

      expect(total_assessments).to eql(assessments_per_phase.sum)
    end
  end

  describe ".get_total_percentage" do
    it "displays learner's total percentage of 6.9" do
      total_percentage = get_total_percentage(4, 58)
      expect(total_percentage).to eql(7)
    end
  end

  describe ".get_progress_status" do
    context "when page is loaded" do
      it "displays leaner's progress status of below-average" do
        status = {
          "6.9": "below-average",
          "60": "average-and-above",
          "100": "completed"
        }
        status.each do |key, value|
          progress_status = get_progress_status(key.to_s.to_i)
          expect(progress_status).to eql(value)
        end
      end
    end
  end

  describe ".get_received_holistic_evaluations" do
    let!(:learner_program) { create :learner_program }
    context "when supplied with program id" do
      it "returns received holistic evaluations" do
        evaluations = get_received_holistic_evaluations(learner_program.id)
        expect(evaluations).to eq(0)
      end
    end
  end

  describe ".lfa_week1" do
    context "when supplied with city and cycle" do
      it "returns all week one lfas " do
        lfa = get_lfas("nairobi", 12)
        expect(lfa.count).to eq(0)
      end
    end
  end

  describe ".lfa_week2" do
    context "when supplied with city and cycle" do
      it "returns all week two lfas " do
        lfa = get_lfas("nairobi", 12)
        expect(lfa.count).to eq(0)
      end
    end
  end

  describe ".filter_selected?" do
    context "when filter param value is an array" do
      it "returns true if value is in the array" do
        is_selected = filter_selected?(%w(1 2), "1")
        expect(is_selected).to be_truthy
      end
    end

    context "when filter param value is a plain text" do
      it "returns true when both values matched" do
        is_selected = filter_selected?("1", "1")
        expect(is_selected).to be_truthy
      end
    end

    describe ".resized_profile_image" do
      before do
        stub_current_user(:user)
        session[:current_user_info] = user.user_info
      end

      it "returns a url string for current user profile image" do
        expect(resized_profile_image).to eq("")
      end
    end

    describe ".language_stacks" do
      before do
        stub_current_user(:user)
        session[:current_user_info] = user.user_info
      end

      it "returns all language stacks" do
        expect(language_stacks.nil?).to eq(false)
      end
    end
  end
end
