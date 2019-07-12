RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "index helper context", share_context: :metadata do
  let(:user) { create :user }
  let(:program) { create :program }
  let!(:programs_phase) do
    create(:programs_phase, program_id: program.id, phase_id: phases[0].id)
  end
  let!(:learner_program) do
    learner_program = create(:learner_program, program: program)
    learner_program
  end
end

RSpec.configure do |rspec|
  rspec.include_context "index helper context", include_shared: true
end
