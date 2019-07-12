require "rails_helper"

RSpec.describe ScoreFacade, type: :facade do
  let(:learner_program) { create :learner_program }
  let(:facade_object) { ScoreFacade.new(learner_program.id) }
  describe "get learner" do
    it "returns learner" do
      expect(facade_object.get_learner.count).to eq 2
    end
  end
end
