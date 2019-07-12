require "rails_helper"
require "spec_helper"

describe LearnerProgramPresenter do
  include ActionView::TestCase::Behavior
  let(:learner_program) { create :learner_program }

  it "returns details of learner program" do
    presenter = LearnerProgramPresenter.new learner_program, view

    expect(presenter.registered).
      to eq learner_program.created_at.strftime "%B %e, %Y"
  end
end
