require "rails_helper"

RSpec.describe AssessmentsControllerHelper, type: :helper do
  let!(:criterium) { create :criterium }
  let!(:framework) { create :framework }
  let!(:learner) do
    create(
      :bootcamper_with_learner_program,
      email: "janedoe@gmail.com"
    )
  end
  let!(:framework_criterium) do
    @request.session[:current_user_info] = { email: "janedoe@gmail.com" }
    create :framework_criterium, framework: framework, criterium: criterium
  end

  describe "#get_criteria_framework" do
    it "returns an array containing both criteria and frameworks" do
      framework_criteria = get_criteria_framework(
        [framework_criterium.criterium]
      )
      expect(framework_criteria.length).to be > 0
      expect(framework_criteria[0][:framework]).to eq framework.name
      expect(framework_criteria[0][:criteria]).to eq criterium.name
    end
  end

  describe "#get_lfa" do
    it "returns current lfa for a fellow" do
      lfa = get_lfa
      facilitator = Facilitator.find(
        learner.learner_programs.last.week_two_facilitator_id
      )
      expect(lfa.email).to eq(facilitator.email)
    end
  end
end
