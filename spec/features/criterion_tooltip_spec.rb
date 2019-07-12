require "rails_helper"

describe "Display criterion tooltip" do
  before :all do
    program = Program.first
    @learner = create(:learner_program, program_id: program.id).bootcamper
    phase = create(:phase)
    create(:programs_phase, program_id: program.id, phase_id: phase.id)

    criterium = create(
      :criterium,
      id: 123,
      name: "EPIC X",
      context: "Awesome People.",
      description: "Excellence, Passion, Integrity & Collaboration."
    )

    assessment = create(
      :assessment,
      phases: [phase],
      criterium: criterium,
      name: "Programming"
    )

    very_satisfied = create(:point, value: 2)
    satisfied = create(:point, value: 1)
    neutral = create(:point, value: 0)
    unsatisfied = create(:point, value: -1)
    very_unsatisfied = create(:point, value: -2)

    create(
      :metric,
      point: very_unsatisfied,
      description: "Strong No.",
      assessment: assessment,
      criteria_id: criterium.id
    )

    create(
      :metric,
      point: unsatisfied,
      description: "Just No.",
      assessment: assessment,
      criteria_id: criterium.id
    )

    create(
      :metric,
      point: neutral,
      description: "It's Okay.",
      assessment: assessment,
      criteria_id: criterium.id
    )

    create(
      :metric,
      point: satisfied,
      description: "Looks Fine.",
      assessment: assessment,
      criteria_id: criterium.id
    )

    create(
      :metric,
      point: very_satisfied,
      description: "Excellent.",
      assessment: assessment,
      criteria_id: criterium.id
    )
  end

  before do
    stub_andelan
    stub_current_session
  end

  feature "holistic evaluation criteria" do
    scenario "user should see criterion tooltip info" do
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      click_on "Learners"
      learner_name = @learner.first_name + " " + @learner.last_name
      click_link(learner_name)
      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      find("#criterion-123").click

      expect(page).to have_content("EPIC X")
      expect(page).to have_content("Awesome People.")
      expect(page).to have_content(
        "Excellence, Passion, Integrity & Collaboration."
      )
      expect(page).to have_content("Strong No.")
      expect(page).to have_content("Just No.")
      expect(page).to have_content("It's Okay.")
      expect(page).to have_content("Looks Fine.")
      expect(page).to have_content("Excellent.")
    end
  end
end
