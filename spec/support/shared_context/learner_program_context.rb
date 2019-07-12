RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "eligibility context", shared_context: :metadata do
  let(:cadence) { create :cadence, days: 1 }
  let(:program) do
    create(:program, estimated_duration: 2, cadence_id: cadence.id)
  end
  let(:learner_program) { create :learner_program, program_id: program.id }
  let(:evaluation_average) { create :evaluation_average }
  let(:phase) { create :phase, name: "Home Study" }
  let!(:programs_phase) do
    create(:programs_phase, program_id: program.id, phase_id: phase.id)
  end
  let(:criterium) { create :criterium }
  let!(:assessment) do
    create(
      :assessment,
      phases: [phase],
      criterium: criterium
    )
  end
end

RSpec.shared_context "create evaluation context", shared_context: :metadata do
  let(:valid_scores) do
    {
      "0":
        {
          criterium_id: criterium.id,
          score: 2,
          comment: "Awesome work"
        }
    }
  end
  let(:missing_scores) do
    {
      "0":
        {
          criterium_id: 10,
          comment: "Awesome job"
        }
    }
  end
end

RSpec.shared_context "update evaluation context", shared_context: :metadata do
  let(:valid_scores) do
    {
      "0":
        {
          id: HolisticEvaluation.last.id,
          criterium_id: criterium.id,
          score: 2,
          comment: "Great work"
        }
    }
  end
  let(:missing_scores) do
    {
      "0":
        {
          id: HolisticEvaluation.last.id,
          criterium_id: 10,
          comment: "cool"
        }
    }
  end
end

RSpec.shared_context "learner program details", shared_context: :metadata do
  let(:program) { create :program }
  let(:phase) { create :phase, name: "Home Session 5" }
  let!(:programs_phase) do
    create(:programs_phase, phase_id: phase.id, program_id: program.id)
  end

  let(:cycle) { create :cycle, cycle: 1 }
  let(:center) { create :center, name: "New York", country: "USA" }
  let(:cycle_center) do
    create(
      :cycle_center,
      program_id: program.id,
      cycle: cycle,
      center: center
    )
  end

  let!(:leaner_program) do
    create(
      :learner_program,
      program_id: program.id,
      cycle_center: cycle_center
    )
  end
end

RSpec.configure do |rspec|
  rspec.include_context "eligibility context", include_shared: true
  rspec.include_context "create evaluation context", include_shared: true
  rspec.include_context "learner program details", include_shared: true
end
