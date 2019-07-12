RSpec.configure do |rspec|
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "feedback details", shared_context: :metadata do
  let(:bootcamper) { create :bootcamper_with_learner_program }
  let(:json) { response.body }
  let(:phase) { create :phase, name: "Home Session 7" }
  let(:impression) { create_list(:impression, 2) }
  let(:learner_program) { create_list(:learner_program, 2) }
  let(:assessment) { create_list(:assessment, 2) }

  let!(:feedback) do
    create :feedback,
           learner_program: learner_program[0],
           phase: phase,
           assessment: assessment[0],
           impression: impression[0],
           comment: "Well done"
  end

  let(:first_details) do
    {
      learner_program_id: learner_program[0].id,
      comment: "Good Implementation",
      phase_id: phase.id,
      impression_id: impression[0].id,
      assessment_id: assessment[0].id
    }
  end

  let(:second_details) do
    {
      learner_program_id: learner_program[1].id,
      comment: "Nice work",
      phase_id: phase.id,
      impression_id: impression[1].id,
      assessment_id: assessment[1].id
    }
  end

  let(:feedback_param) do
    {
      learner_program_id: learner_program[0].id,
      phase_id: phase.id,
      assessment_id: assessment[0].id
    }
  end

  before do
    stub_current_user(:bootcamper)
    session[:current_user_info] = learner_program[0].bootcamper
    session[:current_user_info][:email] = learner_program[0].bootcamper.email
    ProgramsPhase.create(
      program_id: learner_program[0].program.id,
      phase_id: phase.id
    )
  end
end

RSpec.configure do |rspec|
  rspec.include_context "feedback details", include_shared: true
end
