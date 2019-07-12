require "rails_helper"

RSpec.describe CriteriaController, type: :controller do
  include_context "criteria context"

  before do
    stub_current_user(:user)
    controller.stub(:admin?)
    allow(controller).to receive_message_chain("helpers.admin?").and_return true
  end

  describe "GET #get_criteria" do
    it "returns criteria for a framework" do
      get :get_criteria, params: { id: framework_criteria.framework.id,
                                   program_id: program.id }

      expect(json.size).to be <= framework_criteria.framework.criteria.size
    end
  end

  describe "GET #get_framework_criterium_id" do
    it "returns the framework_criterium_id" do
      criterium_id = framework_criteria.framework.criteria[0].id
      framework_id = framework_criteria.framework.id

      get :get_framework_criterium_id, params:
          { criterium_id: criterium_id, framework_id: framework_id }

      framework_criteria_id = FrameworkCriterium.find_by(
        criterium_id: criterium_id,
        framework_id: framework_id
      )

      expect(json).to eq framework_criteria_id.id
    end
  end
end
